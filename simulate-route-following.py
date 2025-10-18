#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
#     "polyline",
# ]
# ///

import argparse
import math
import random
import subprocess
import time
import sys
import requests
import polyline


def execute_redis_batch(commands):
    """Execute multiple Redis commands in a single MULTI transaction"""
    redis_input = "MULTI\n" + "\n".join(commands) + "\nEXEC"
    subprocess.run(["redis-cli"], input=redis_input, text=True,
                   check=True, stdout=subprocess.DEVNULL)


def get_redis_value(hash_name, field, default=None):
    """Get a value from Redis using redis-cli"""
    try:
        result = subprocess.run(
            ["redis-cli", "HGET", hash_name, field],
            capture_output=True,
            text=True,
            check=True
        )
        value = result.stdout.strip()
        if value:
            return value
        return default
    except (subprocess.SubprocessError, ValueError):
        return default


def get_route(start, end):
    """Get a route from Valhalla"""
    valhalla_url = "https://valhalla1.openstreetmap.de/route"

    request_data = {
        "locations": [
            {"lat": start[0], "lon": start[1]},
            {"lat": end[0], "lon": end[1]}
        ],
        "costing": "motor_scooter",
        "units": "kilometers"
    }

    try:
        response = requests.post(valhalla_url, json=request_data)
        response.raise_for_status()
        route_data = response.json()
        shape = route_data['trip']['legs'][0]['shape']
        return polyline.decode(shape, 6)
    except requests.exceptions.RequestException as e:
        print(f"Error getting route from Valhalla: {e}")
        return None


def haversine(lat1, lon1, lat2, lon2):
    """Calculate the distance between two points in meters."""
    R = 6371000  # Earth radius in meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = math.sin(delta_phi / 2) * math.sin(delta_phi / 2) + \
        math.cos(phi1) * math.cos(phi2) * \
        math.sin(delta_lambda / 2) * math.sin(delta_lambda / 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    return R * c


def calculate_bearing(lat1, lon1, lat2, lon2):
    """Calculate bearing from point 1 to point 2 in degrees."""
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    dLon = math.radians(lon2 - lon1)

    y = math.sin(dLon) * math.cos(lat2_rad)
    x = math.cos(lat1_rad) * math.sin(lat2_rad) - \
        math.sin(lat1_rad) * math.cos(lat2_rad) * math.cos(dLon)

    bearing = math.degrees(math.atan2(y, x))
    return (bearing + 360) % 360


def calculate_turn_angle(bearing1, bearing2):
    """Calculate the turn angle between two bearings (absolute value)."""
    diff = abs(bearing2 - bearing1)
    if diff > 180:
        diff = 360 - diff
    return diff


def get_target_speed_for_upcoming_turns(current_pos, waypoints, waypoint_index, max_speed, look_ahead_distance=50):
    """Calculate appropriate speed based on upcoming turns within look_ahead_distance meters.

    Returns: (target_speed, max_turn_angle, turn_description)
    """
    if waypoint_index >= len(waypoints) - 2:
        return max_speed, 0, "straight"

    # Look ahead through waypoints
    accumulated_distance = 0
    prev_bearing = None
    max_turn_angle = 0

    for i in range(waypoint_index, min(waypoint_index + 10, len(waypoints) - 1)):
        wp1 = waypoints[i]
        wp2 = waypoints[i + 1]

        segment_distance = haversine(wp1[0], wp1[1], wp2[0], wp2[1])

        # Calculate bearing for this segment
        bearing = calculate_bearing(wp1[0], wp1[1], wp2[0], wp2[1])

        # If we have a previous bearing, calculate turn angle
        if prev_bearing is not None:
            turn_angle = calculate_turn_angle(prev_bearing, bearing)
            max_turn_angle = max(max_turn_angle, turn_angle)

        prev_bearing = bearing
        accumulated_distance += segment_distance

        if accumulated_distance > look_ahead_distance:
            break

    # Adjust speed based on sharpest turn ahead (more conservative for city riding)
    if max_turn_angle < 15:  # Gentle turn or straight
        return max_speed, max_turn_angle, "straight"
    elif max_turn_angle < 30:  # Moderate turn
        return max_speed * 0.65, max_turn_angle, "gentle turn"  # ~37 km/h
    elif max_turn_angle < 60:  # Sharp turn
        return max_speed * 0.45, max_turn_angle, "sharp turn"  # ~26 km/h
    elif max_turn_angle < 90:  # Very sharp turn
        return max_speed * 0.35, max_turn_angle, "very sharp"  # ~20 km/h
    else:  # Hairpin (90+ degrees)
        return max_speed * 0.25, max_turn_angle, "hairpin"  # ~14 km/h


class TrafficEvent:
    """Represents a traffic event that affects speed."""
    def __init__(self, event_type, duration, speed_limit):
        self.type = event_type  # 'stop', 'slow', 'traffic_light'
        self.duration = duration  # How many updates this event lasts
        self.speed_limit = speed_limit  # Max speed during this event
        self.remaining = duration


def generate_traffic_event(at_intersection=False):
    """Randomly generate a traffic event.

    Args:
        at_intersection: True if approaching a turn, increases chance of traffic light
    """
    rand = random.random()

    # Low chance of stops at intersections (traffic lights)
    stop_chance = 0.03 if at_intersection else 0.005

    if rand < stop_chance:  # Full stop (traffic light, stop sign, pedestrian)
        duration = random.randint(4, 12)  # 2-6 seconds at 2Hz
        event_type = 'traffic_light' if at_intersection else 'stop'
        return TrafficEvent(event_type, duration, 0)
    elif rand < 0.05:  # 4.5% chance: Slow traffic (congestion, yielding)
        duration = random.randint(6, 16)  # 3-8 seconds
        speed_limit = random.uniform(20, 35)  # 20-35 km/h
        return TrafficEvent('slow', duration, speed_limit)
    elif rand < 0.10:  # 5% chance: Moderate slowdown (following another vehicle)
        duration = random.randint(8, 24)  # 4-12 seconds
        speed_limit = random.uniform(35, 48)  # 35-48 km/h
        return TrafficEvent('following', duration, speed_limit)

    return None


def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description='Simulate GPS route following with realistic vehicle dynamics'
    )
    parser.add_argument('start_lat', type=float, help='Starting latitude')
    parser.add_argument('start_lon', type=float, help='Starting longitude')
    parser.add_argument('dest_lat', nargs='?', type=float, help='Destination latitude (optional)')
    parser.add_argument('dest_lon', nargs='?', type=float, help='Destination longitude (optional)')
    parser.add_argument('--set-destination', action='store_true',
                        help='Set the destination in Redis navigation hash for UI display')
    args = parser.parse_args()

    # Validate destination arguments
    if (args.dest_lat is None) != (args.dest_lon is None):
        parser.error('Both destination latitude and longitude must be provided together')

    # Simulation timing - easily adjustable
    updates_per_second = 2.0  # Change this to adjust update frequency
    update_interval = 1.0 / updates_per_second

    # Initialize variables
    lat = args.start_lat
    lon = args.start_lon
    specified_destination = (args.dest_lat, args.dest_lon) if args.dest_lat is not None else None

    course = 0
    max_speed = 57                   # Maximum speed in km/h
    max_acceleration = 11.5          # Maximum acceleration (km/h per second) - 0 to 57 km/h in ~5s
    max_deceleration = 30            # Maximum deceleration (km/h per second) - can stop from 57 km/h in ~1.9s
    earth_radius = 6371.0            # Earth radius in km
    target_speed = max_speed * 0.7   # Initial target speed

    # Engine variables
    current_speed = 0                # Current speed in km/h
    prev_speed = 0                   # Previous speed in km/h

    # Motor variables
    min_voltage = 48.0               # Minimum voltage (V)
    max_voltage = 57.0               # Maximum voltage (V)
    nominal_voltage = 53.0           # Nominal voltage when cruising (V)
    battery_state = 0.8              # Battery state of charge (0.0-1.0)

    # Get current odometer value from Redis or initialize to 0
    odometer = float(get_redis_value("engine-ecu", "odometer", 0))

    print(f"Starting simulation from latitude: {lat}, longitude: {lon}")
    print(f"Initial odometer reading: {odometer} meters")
    print("Press Ctrl+C to stop")

    route_waypoints = []
    waypoint_index = 0

    # Traffic simulation state
    current_traffic_event = None

    # Set destination in Redis if requested (only once at start)
    if args.set_destination:
        if specified_destination:
            dest_lat, dest_lon = specified_destination
        else:
            # Generate random destination
            dest_lat = lat + (random.random() - 0.5) * 0.1  # approx 5km radius
            dest_lon = lon + (random.random() - 0.5) * 0.1

        dest_str = f"{dest_lat},{dest_lon}"
        nav_commands = [
            f"HSET navigation destination {dest_str}",
            "PUBLISH navigation destination"
        ]
        execute_redis_batch(nav_commands)
        print(f"Set navigation destination in Redis: {dest_str}")

    try:
        # Main loop
        while True:
            if not route_waypoints or waypoint_index >= len(route_waypoints) - 1:
                # Determine destination: Redis first, then specified args, then random
                destination_str = get_redis_value("navigation", "destination")
                if destination_str:
                    dest_lat, dest_lon = map(float, destination_str.split(','))
                    print(f"Using destination from Redis: {dest_lat}, {dest_lon}")
                elif specified_destination:
                    dest_lat, dest_lon = specified_destination
                    print(f"Using specified destination: {dest_lat}, {dest_lon}")
                else:
                    # Generate random destination
                    dest_lat = lat + (random.random() - 0.5) * 0.1  # approx 5km radius
                    dest_lon = lon + (random.random() - 0.5) * 0.1
                    print(f"Generating random destination: {dest_lat}, {dest_lon}")

                # Get the route
                route_waypoints = get_route((lat, lon), (dest_lat, dest_lon))

                if not route_waypoints:
                    print("Could not get a route. Waiting...")
                    time.sleep(5)
                    continue

                waypoint_index = 0

            # Store previous speed for calculating delta
            prev_speed = current_speed

            # Calculate target speed based on upcoming turns
            turn_based_target, turn_angle, turn_desc = get_target_speed_for_upcoming_turns(
                (lat, lon), route_waypoints, waypoint_index, max_speed, look_ahead_distance=50
            )

            # Detect if we're approaching an intersection (turn > 30 degrees)
            at_intersection = turn_angle > 30

            # Update or generate traffic events
            if current_traffic_event is not None:
                current_traffic_event.remaining -= 1
                if current_traffic_event.remaining <= 0:
                    current_traffic_event = None
            else:
                # No active event, maybe generate a new one
                current_traffic_event = generate_traffic_event(at_intersection=at_intersection)

            # Apply traffic limitations
            traffic_desc = "clear"
            if current_traffic_event is not None:
                turn_based_target = min(turn_based_target, current_traffic_event.speed_limit)
                traffic_desc = current_traffic_event.type

            # Add some random variation (±3 km/h) to make it more realistic
            speed_variation = random.uniform(-3, 3)
            target_speed = max(0, min(max_speed, turn_based_target + speed_variation))

            # Apply acceleration or deceleration limits, scaled by update interval
            if target_speed > prev_speed:
                # Accelerating - use slower acceleration rate
                speed_delta_per_update = max_acceleration * update_interval
                current_speed = min(target_speed, prev_speed + speed_delta_per_update)
            else:
                # Decelerating - use faster deceleration rate (strong braking)
                speed_delta_per_update = max_deceleration * update_interval
                current_speed = max(target_speed, prev_speed - speed_delta_per_update)

            # Calculate distance traveled in this update interval (km)
            distance_km = (current_speed / 3600) * update_interval
            distance_meters = distance_km * 1000
            odometer += distance_meters
            rounded_odometer = round(odometer / 100) * 100

            # Move along the route
            distance_to_travel = distance_km * 1000  # in meters
            while distance_to_travel > 0 and waypoint_index < len(route_waypoints) - 1:
                p_next = route_waypoints[waypoint_index + 1]
                dist_to_next_wp = haversine(lat, lon, p_next[0], p_next[1])

                # If we are very close to the next waypoint, just snap to it
                if dist_to_next_wp < 0.1:
                    waypoint_index += 1
                    continue

                if distance_to_travel >= dist_to_next_wp:
                    distance_to_travel -= dist_to_next_wp
                    lat, lon = p_next
                    waypoint_index += 1
                else:
                    # Interpolate between current position and the next waypoint
                    ratio = distance_to_travel / dist_to_next_wp
                    lat = lat + (p_next[0] - lat) * ratio
                    lon = lon + (p_next[1] - lon) * ratio
                    distance_to_travel = 0

            # Calculate course from current position to next waypoint
            if waypoint_index < len(route_waypoints) - 1:
                p_current = (lat, lon)
                p_next = route_waypoints[waypoint_index + 1]

                # Only update course if we are actually moving
                if haversine(p_current[0], p_current[1], p_next[0], p_next[1]) > 0.1:
                    lat1_rad = math.radians(p_current[0])
                    lon1_rad = math.radians(p_current[1])
                    lat2_rad = math.radians(p_next[0])
                    lon2_rad = math.radians(p_next[1])

                    dLon = lon2_rad - lon1_rad
                    y = math.sin(dLon) * math.cos(lat2_rad)
                    x = math.cos(lat1_rad) * math.sin(lat2_rad) - \
                        math.sin(lat1_rad) * math.cos(lat2_rad) * \
                        math.cos(dLon)
                    course = (math.degrees(math.atan2(y, x)) + 360) % 360

            # Format to 6 decimal places for GPS
            lat_formatted = f"{lat:.6f}"
            lon_formatted = f"{lon:.6f}"

            # Batch all Redis updates in a single transaction
            engine_speed = int(round(current_speed))

            redis_commands = [
                f"HSET gps latitude {lat_formatted}",
                f"PUBLISH gps latitude",
                f"HSET gps longitude {lon_formatted}",
                f"PUBLISH gps longitude",
                f"HSET gps course {course}",
                f"PUBLISH gps course",
                f"HSET engine-ecu speed {engine_speed}",
                f"HSET engine-ecu odometer {int(rounded_odometer)}"
            ]

            execute_redis_batch(redis_commands)

            print(
                f"GPS: lat={lat_formatted}, lon={lon_formatted}, course={course:.1f}°")
            print(
                f"Engine: speed={engine_speed}km/h (target: {int(round(target_speed))}km/h)")
            print(f"Road: {turn_desc} ahead (turn angle: {turn_angle:.1f}°)")
            print(f"Traffic: {traffic_desc}")
            print(f"Odometer: {int(rounded_odometer)}m")
            print()

            time.sleep(update_interval)

    except KeyboardInterrupt:
        print("\nSimulation stopped")
        sys.exit(0)


if __name__ == "__main__":
    main()
