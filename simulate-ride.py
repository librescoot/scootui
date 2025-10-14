#!/usr/bin/env python3

import math
import random
import subprocess
import time
import sys


def execute_redis_batch(commands):
    """Execute multiple Redis commands in a single MULTI transaction"""
    redis_input = "MULTI\n" + "\n".join(commands) + "\nEXEC"
    subprocess.run(["redis-cli"], input=redis_input, text=True, check=True, stdout=subprocess.DEVNULL)


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
        return float(value) if value else default
    except (subprocess.SubprocessError, ValueError):
        return default


def main():
    # Simulation timing - easily adjustable
    updates_per_second = 1.0  # Change this to adjust update frequency
    update_interval = 1.0 / updates_per_second
    
    # Check command line arguments
    if len(sys.argv) not in [3, 4]:
        print(f"Usage: {sys.argv[0]} <starting_latitude> <starting_longitude> [bearing]")
        print("  bearing: optional fixed bearing in degrees (0-359), disables course changes")
        sys.exit(1)

    # Initialize variables
    lat = float(sys.argv[1])
    lon = float(sys.argv[2])
    
    if len(sys.argv) == 4:
        # Fixed bearing mode - travel in straight line
        course = float(sys.argv[3]) % 360
        max_course_change = 0  # No course changes
        print(f"Fixed bearing mode: {course}°")
    else:
        # Random course mode
        course = random.randint(0, 359)  # Random initial course (0-359 degrees)
        max_course_change = 5  # Maximum course change per second (degrees)
    # Direction bias - tends to continue in similar direction
    direction_bias = 0
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
    odometer = get_redis_value("engine-ecu", "odometer", 0)

    print(f"Starting simulation from latitude: {lat}, longitude: {lon}")
    print(f"Initial odometer reading: {odometer} meters")
    print("Press Ctrl+C to stop")

    try:
        # Main loop
        while True:
            # Store previous speed for calculating delta
            prev_speed = current_speed

            # Update course with smoother, more realistic changes
            # 70% chance of small course correction, 30% chance of continuing straight
            if random.random() < 0.7:
                # Bias toward continuing in similar direction with small corrections
                course_change = random.uniform(-max_course_change, max_course_change)
                # Apply direction bias (momentum in current direction)
                direction_bias = direction_bias * 0.8 + course_change * 0.2
                course_change = direction_bias
            else:
                # Continue straight (no course change)
                course_change = 0
                direction_bias *= 0.9  # Gradually reduce bias when going straight
            
            course = (course + course_change) % 360

            # Update target speed more gradually and independently
            # Only change target speed occasionally (20% chance per second)
            if random.random() < 0.2:
                # Occasionally adjust target speed for variety
                target_speed_change = random.uniform(-5, 5)
                new_target = target_speed + target_speed_change
                target_speed = max(20, min(max_speed, new_target))
            
            # Reduce target speed slightly when making sharp turns
            if abs(course_change) > 2:
                turn_speed_reduction = min(5, abs(course_change))
                target_speed = max(target_speed - turn_speed_reduction, 20)

            # Apply acceleration or deceleration limits, scaled by update interval
            if target_speed > prev_speed:
                # Accelerating - use slower acceleration rate
                speed_delta_per_update = max_acceleration * update_interval
                current_speed = min(target_speed, prev_speed + speed_delta_per_update)
            else:
                # Decelerating - use faster deceleration rate (strong braking)
                speed_delta_per_update = max_deceleration * update_interval
                current_speed = max(target_speed, prev_speed - speed_delta_per_update)

            # Calculate actual speed delta (change in speed)
            speed_delta = current_speed - prev_speed

            # Calculate engine power based on speed delta
            if speed_delta < 0:  # Slowing down
                # Map from [min_delta..0] to [-10..0]
                # Using max_deceleration as the reference for mapping
                power = (speed_delta / (max_deceleration * update_interval)) * 10.0
                power = max(-10.0, min(0.0, power))
            else:  # Speeding up or maintaining speed
                # Map from [0..max_delta] to [0..70]
                # Using max_acceleration as the reference for mapping
                power = (speed_delta / (max_acceleration * update_interval)) * 70.0
                power = max(0.0, min(70.0, power))

            # Calculate motor voltage based on power, speed, and battery state
            # Voltage drops under load (acceleration) and rises with regeneration (braking)
            # Also introduce small random fluctuations
            # Base voltage depends on battery state
            base_voltage = min_voltage + \
                (max_voltage - min_voltage) * battery_state

            # Voltage drops under load (positive power) and increases during regeneration (negative power)
            # We scale the effect based on max power (70)
            power_effect = -3.0 * (power / 70.0)  # Max 3V drop at full power

            # Speed effect: voltage sags slightly at higher speeds due to internal resistance
            speed_effect = -1.0 * (current_speed / max_speed) * 0.5

            # Random small fluctuations (+/- 0.2V)
            random_fluctuation = (random.random() - 0.5) * 0.4

            # Calculate final voltage with limits
            voltage = base_voltage + power_effect + speed_effect + random_fluctuation
            voltage = max(min_voltage, min(max_voltage, voltage))

            # Format voltage to 1 decimal place
            motor_voltage = round(voltage, 1) * 100

            # Calculate distance traveled in this update interval (km)
            distance_km = (current_speed / 3600) * update_interval

            # Calculate distance in meters for odometer
            distance_meters = distance_km * 1000

            # Update odometer in steps of 100m
            # First accumulate the exact distance
            odometer += distance_meters
            # Then round to nearest 100m for display/storage
            rounded_odometer = round(odometer / 100) * 100

            # Convert to radians for position calculation
            lat_rad = math.radians(lat)
            lon_rad = math.radians(lon)
            course_rad = math.radians(course)
            angular_distance = distance_km / earth_radius

            # Simple coordinate update using direct trigonometry
            # GPS course: 0° = North, 90° = East, 180° = South, 270° = West
            # Convert to standard math coordinates where 0° = East, 90° = North
            math_bearing = (90 - course) % 360
            math_bearing_rad = math.radians(math_bearing)
            
            # Calculate displacement in meters
            displacement_m = distance_km * 1000
            
            # Approximate coordinate changes (good enough for short distances)
            # 1 degree latitude ≈ 111,111 meters
            # 1 degree longitude ≈ 111,111 * cos(latitude) meters
            lat_change = (displacement_m * math.sin(math_bearing_rad)) / 111111
            lon_change = (displacement_m * math.cos(math_bearing_rad)) / (111111 * math.cos(math.radians(lat)))
            
            # Update position
            lat += lat_change
            lon += lon_change

            # Normalize longitude to -180 to 180
            lon = ((lon + 180) % 360) - 180

            # Format to 6 decimal places for GPS
            lat_formatted = f"{lat:.6f}"
            lon_formatted = f"{lon:.6f}"

            # Batch all Redis updates in a single transaction
            engine_speed = int(round(current_speed))
            engine_power = round(power, 1)
            
            redis_commands = [
                f"HSET gps latitude {lat_formatted}",
                f"PUBLISH gps latitude",
                f"HSET gps longitude {lon_formatted}",
                f"PUBLISH gps longitude",
                f"HSET gps course {course}",
                f"PUBLISH gps course",
                f"HSET engine-ecu speed {engine_speed}",
                f"HSET engine-ecu motor:current {engine_power * 100}",
                f"HSET engine-ecu motor:voltage {motor_voltage * 100}",
                f"HSET engine-ecu odometer {int(rounded_odometer)}"
            ]
            
            execute_redis_batch(redis_commands)

            # Calculate target speed for display
            target_speed_int = int(round(target_speed))

            print(
                f"GPS: lat={lat_formatted}, lon={lon_formatted}, course={course}°")
            print(
                f"Engine: speed={engine_speed}km/h (target: {target_speed_int}km/h), power={engine_power}, delta={speed_delta:.2f}km/h")
            print(
                f"Motor: voltage={motor_voltage}V, current={engine_power}A")
            print(
                f"Odometer: {int(rounded_odometer)}m (traveled {int(distance_meters)}m this tick)")

            # Wait for the update interval
            time.sleep(update_interval)

    except KeyboardInterrupt:
        print("\nSimulation stopped")
        sys.exit(0)


if __name__ == "__main__":
    main()
