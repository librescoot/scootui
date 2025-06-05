#!/usr/bin/env python3

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
    valhalla_url = "https://valhalla1.openstreetmap.de//route"

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


def main():
    # Simulation timing - easily adjustable
    updates_per_second = 2.0  # Change this to adjust update frequency
    update_interval = 1.0 / updates_per_second

    # Check command line arguments
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <starting_latitude> <starting_longitude>")
        sys.exit(1)

    # Initialize variables
    lat = float(sys.argv[1])
    lon = float(sys.argv[2])

    course = 0
    max_speed = 57                   # Maximum speed in km/h
    # Maximum speed change per second (km/h) - more realistic acceleration
    max_speed_delta = 8
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

    try:
        # Main loop
        while True:
            if not route_waypoints or waypoint_index >= len(route_waypoints) - 1:
                # Get new route
                destination_str = get_redis_value("navigation", "destination")
                if destination_str:
                    dest_lat, dest_lon = map(float, destination_str.split(','))
                    print(
                        f"Found destination in Redis: {dest_lat}, {dest_lon}")
                    route_waypoints = get_route(
                        (lat, lon), (dest_lat, dest_lon))
                else:
                    # Generate random destination
                    dest_lat = lat + (random.random() - 0.5) * \
                        0.1  # approx 5km radius
                    dest_lon = lon + (random.random() - 0.5) * 0.1
                    print(
                        f"No destination set, generating random one: {dest_lat}, {dest_lon}")
                    route_waypoints = get_route(
                        (lat, lon), (dest_lat, dest_lon))

                if not route_waypoints:
                    print("Could not get a route. Waiting...")
                    time.sleep(5)
                    continue

                waypoint_index = 0

            # Store previous speed for calculating delta
            prev_speed = current_speed

            # Update target speed more gradually and independently
            if random.random() < 0.4:
                target_speed_change = random.uniform(-4, 5)
                new_target = target_speed + target_speed_change
                target_speed = max(30, min(max_speed, new_target))

            # Limit speed change to max_speed_delta per second
            if target_speed > prev_speed:
                current_speed = min(target_speed, prev_speed + max_speed_delta)
            else:
                current_speed = max(target_speed, prev_speed - max_speed_delta)

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
                f"HSET gps longitude {lon_formatted}",
                f"PUBLISH gps location-updated",
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
            print(f"Odometer: {int(rounded_odometer)}m")

            time.sleep(update_interval)

    except KeyboardInterrupt:
        print("\nSimulation stopped")
        sys.exit(0)


if __name__ == "__main__":
    main()
