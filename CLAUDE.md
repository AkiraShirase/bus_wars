# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bus Wars is a 2D isometric bus driving simulator and visual novel built with Godot 4.4. Players drive buses in city levels, competing with other companies to transport passengers between bus stops while building routes and managing bus customization.

## Key Architecture

### Core Components

- **Bus System** (`player/`): Modular bus construction with separate components
  - `Bus` class (`truck.gd`): Main vehicle controller with physics and component integration
  - Component classes: `BusMaterial`, `PassengerSection`, `TireMaterial`, `EnginePower`, `PowerSource`
  - Debug systems: `BusDebugUI.gd`, `BusDebugVectors.gd`

- **Level System** (`levels/`):
  - `city.gd`: Main level controller and camera management
  - `IsometricRoad.gd`: Road generation with point-based properties (gravity, friction effects)
  - `road.gd`: Basic road functionality
  - `RoadPointData.gd`: Data structure for road point properties

### Physics and Movement

- Custom 2D isometric physics system (gravity disabled: `2d/default_gravity=0.0`)
- Bus physics based on component parameters (weight, engine power, tire properties)
- Road interaction system with gravity effects and surface properties
- Input mapping: W/Up (accelerate), S/Down (brake), A/Left and D/Right (steering)

### Project Structure

- **Main scene**: Configured in `project.godot` as the entry point
- **Tile system**: Uses `tile_map_layer.tscn` for level layout
- **Resolution**: 1280x960 with integer scaling for pixel-perfect rendering
- **Input**: Supports both keyboard (WASD/arrows) and gamepad controls

## Development Commands

This is a Godot project - no traditional package manager commands. Development workflow:

1. **Open Project**: Open `project.godot` in Godot Editor
2. **Run Game**: F5 or play button in Godot Editor
3. **Run Main Scene**: F6 or scene play button
4. **Debug**: Built-in Godot debugger and profiler

## Key Systems to Understand

### Bus Component System
Buses are built from modular components that affect performance:
- Material affects weight and durability
- Engine power affects acceleration and max speed
- Tire material affects handling and braking
- Power source determines available engine options
- Passenger sections affect capacity and weight

### Road Properties System
Roads use `RoadPointData` to define varying properties along their length:
- Gravity effects (road banking, slopes)
- Surface friction
- Visual properties for debugging

### Debug System
Extensive debug UI showing:
- Real-time bus component stats
- Physics vectors and forces
- Performance metrics
- Road property visualization

## Code Conventions

- Uses GDScript with Godot 4.x syntax
- Class names use PascalCase (e.g., `IsometricRoad`)
- Export groups organize inspector properties
- Tool scripts marked with `@tool` for editor functionality
- Component-based architecture with composition over inheritance