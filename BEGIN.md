# BEGIN.md - Starting Bus Wars Development in Godot v4

This document outlines the essential steps to initialize and begin development of the Bus Wars game project in Godot v4.

## Prerequisites

1. **Install Godot v4**: Download the latest stable version of Godot 4.x from [godotengine.org](https://godotengine.org/download)
2. **System Requirements**: Ensure your system meets Godot 4's requirements (OpenGL 3.3 or Vulkan support)

## Project Initialization

### 1. Create New Godot Project
- Open Godot Project Manager
- Click "Create" → "New Project"
- Set project path to this repository directory (`/home/user/bus_wars/`)
- Choose "3D" renderer (for isometric 2.5D gameplay)
- Enable "Version Control Metadata" for Git integration

### 2. Initial Project Structure
Create the following directory structure in the project:
```
scenes/
├── levels/          # City levels and environments
├── ui/              # User interface scenes
├── buses/           # Bus vehicle scenes
├── characters/      # Passenger and driver scenes
└── managers/        # Game system managers

scripts/
├── core/            # Core game systems
├── vehicles/        # Bus physics and behavior
├── passengers/      # Passenger AI and properties
├── routes/          # Route management system
└── companies/       # Company competition logic

assets/
├── textures/        # Sprites and textures
├── models/          # 3D models (if needed)
├── audio/           # Sound effects and music
└── data/            # Game data files (JSON, CSV)
```

### 3. Core Scene Setup

#### Main Scene Structure
1. Create `scenes/Main.tscn` as the root scene
2. Set up basic scene hierarchy:
   ```
   Main (Node3D)
   ├── GameManager (Node)
   ├── UI (CanvasLayer)
   ├── CameraController (Node3D)
   └── Level (Node3D)
   ```

#### Camera Configuration for Isometric View
- Set camera to orthogonal projection
- Position at angle for isometric perspective (typically 30-45 degrees)
- Configure appropriate zoom and FOV settings

### 4. Essential Scripts to Create First

1. **GameManager.gd** - Central game state management
2. **CameraController.gd** - Isometric camera movement and controls
3. **Bus.gd** - Base bus vehicle class with physics
4. **Passenger.gd** - Passenger behavior and properties
5. **BusStop.gd** - Bus stop functionality
6. **Route.gd** - Route definition and management

### 5. Core Systems Implementation Order

1. **Camera and Input System**
   - Implement isometric camera controls
   - Set up input mapping for vehicle controls

2. **Basic Vehicle Physics**
   - Create bus movement with acceleration/deceleration
   - Implement steering and weight-based handling

3. **Level Foundation**
   - Create a simple test level with roads
   - Add basic collision detection for roads/boundaries

4. **Bus Stops System**
   - Place bus stops on the test level
   - Implement passenger spawning at stops

5. **Route Planning**
   - Basic route creation between bus stops
   - Visual representation of routes

### 6. Project Settings Configuration

#### Input Map
Set up input actions for:
- `accelerate` (W key, Up arrow)
- `brake` (S key, Down arrow)
- `steer_left` (A key, Left arrow)
- `steer_right` (D key, Right arrow)
- `camera_pan` (Middle mouse button)
- `camera_zoom` (Mouse wheel)

#### Physics Settings
- Configure physics layers for buses, roads, buildings, passengers
- Set up collision detection between different object types

#### Rendering
- Enable 2D pixel snap for consistent sprite rendering
- Configure shadow settings for isometric lighting

### 7. Version Control Setup

Create `.gitignore` for Godot projects:
```
# Godot 4+ specific ignores
.godot/
.import/
export.cfg
export_presets.cfg

# Mono-specific ignores
.mono/
data_*/
mono_crash.*.json
```

### 8. Initial Testing Scene

Create a minimal playable prototype:
- One small level with a few bus stops
- One controllable bus
- Basic passenger pickup/dropoff mechanics
- Simple win condition (transport X passengers)

## Next Development Phases

After completing the base structure:

1. **Phase 1**: Expand vehicle customization system
2. **Phase 2**: Implement company competition mechanics  
3. **Phase 3**: Add passenger AI and route optimization
4. **Phase 4**: Create multiple levels and progression system
5. **Phase 5**: Polish UI, audio, and visual effects

## Development Tools and Workflow

- Use Godot's built-in script editor or configure external editor (VS Code with Godot plugin)
- Set up scene instancing for reusable components (buses, stops, passengers)
- Use resource files (.tres) for game data (bus configurations, passenger types)
- Implement proper signals for decoupled system communication

This foundation will provide a solid starting point for developing the Bus Wars game concept outlined in the README.