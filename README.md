# ScootUI - LibreScoot's User Interface

ScootUI is the user interface component for the LibreScoot electric scooter project. It's a Flutter application designed to run on a display mounted on electric scooters, providing riders with real-time information, controls, and navigation capabilities.

[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

## 🚀 Features

- **Real-time Telemetry Display**
  - Speed, power output, battery levels, odometer, trip meter
  - GPS status, connectivity indicators, and system warnings

- **Multiple View Modes**
  - Cluster view with speedometer and vehicle status
  - Map view with navigation capabilities
  - Destination selection screen
  - OTA update interface

- **Navigation**
  - Online and offline map support (using MBTiles)
  - Integration with routing services (BRouter)
  - Turn-by-turn directions

- **System Integration**
  - Connects to the scooter's main data bus (Redis-based MDB)
  - Handles battery, engine, GPS, Bluetooth, and other vehicle systems
  - Support for over-the-air (OTA) updates

- **Adaptable Design**
  - Light and dark themes

## 🔧 Technology Stack

- **Flutter/Dart** - UI framework and language
- **Bloc/Cubit** - State management
- **Redis** - Real-time data communication
- **Flutter Map** - Mapping and navigation display
- **MBTiles** - Offline map data storage

## 💻 Development

ScootUI includes a simulator mode for development and testing without physical scooter hardware. It's designed to run on various platforms:

- Embedded Linux systems (target hardware)
- Desktop development environments (macOS, Windows, Linux)
- Mobile devices (for testing)

## 📋 Project Structure

- **cubits/** - State management components
- **repositories/** - Data access layer
- **screens/** - Main UI screens
- **services/** - System services (Redis, map, settings)
- **state/** - Vehicle state data models
- **widgets/** - Reusable UI components

## ⚙️ Configuration

ScootUI uses Redis for dynamic configuration. Settings are stored in the `settings` hash and can be modified at runtime.

### Dashboard Display Settings

| Key | Possible Values | Default | Description |
|-----|-----------------|---------|-------------|
| `dashboard.show-raw-speed` | `true`, `false` | `false` | Show uncorrected speed as reported by ECU instead of wheel circumference corrected speed |
| `dashboard.show-gps` | `always`, `active-or-error`, `error`, `never` | `error` | GPS icon visibility: always show, when GPS has fix or error, error only, or never |
| `dashboard.show-bluetooth` | `always`, `active-or-error`, `error`, `never` | `active-or-error` | Bluetooth icon visibility: always show, when connected or error, error only, or never |
| `dashboard.show-cloud` | `always`, `active-or-error`, `error`, `never` | `error` | Cloud connection icon visibility: always show, when connected or error, error only, or never |
| `dashboard.show-internet` | `always`, `active-or-error`, `error`, `never` | `always` | Internet/cellular icon visibility: always show, when connected or error, error only, or never |

### Map Settings

| Key | Possible Values | Default | Description |
|-----|-----------------|---------|-------------|
| `dashboard.map.type` | `online`, `offline` | `offline` | Map source: online uses CartoDB tiles, offline uses local MBTiles |
| `dashboard.map.render-mode` | `vector`, `raster` | `raster` | Rendering mode for offline maps: vector for dynamic styling, raster for pre-rendered tiles |

**Examples:**
```bash
# Show raw GPS speed on dashboard
redis-cli hset settings dashboard.show-raw-speed true

# Always show GPS indicator
redis-cli hset settings dashboard.show-gps always

# Switch to online maps
redis-cli hset settings dashboard.map.type online

# Use vector rendering for offline maps
redis-cli hset settings dashboard.map.render-mode vector
```

## 📱 Screens

- **Cluster Screen** - Main dashboard with speedometer and vehicle status
- **Map Screen** - Navigation view with location and routing
- **Address Selection** - Destination input interface
- **OTA Screen** - System update interface

## 🔄 Contributing

Contributions to ScootUI are welcome. When contributing, please follow the existing code style and patterns.

## 📜 License

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg


