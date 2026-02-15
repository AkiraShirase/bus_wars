# Bus Wars Architecture

## Overview

Bus Wars is a 2D isometric bus driving simulator and visual novel built with Godot 4.4. The architecture follows a component-based design pattern with modular controllers for vehicle physics, input handling, and level management.

## Core Systems

### 1. Vehicle System

The vehicle system implements a modular bus construction where physics and behavior are determined by pluggable components.

#### GameVehicle (lib/GameVehicle.gd)

Main vehicle class extending `CharacterBody2D`. Serves as the vehicle chassis that integrates all components.

**Key Properties:**
- **Bus Components**: Material, passengers, tires, engine, power source (export groups)
- **Movement**: `base_max_speed`, `base_friction`, `current_speed`, `velocity`, `direction`
- **Isometric Settings**: `isometric_angle`, `tile_size`, `override_angle`, `override_tile_size`
- **Road Interaction**: Checks road properties to apply gravity effects and surface properties
- **Debug**: Optional debug UI and vector visualization

**Key Methods:**
- `add_passengers_at_stop(count)` / `remove_passengers_at_stop(count)` - Manage passenger capacity
- `refuel_bus(delta)` - Refuel from power source
- `direct(new_direction)` - Set vehicle direction and rotation
- `change_speed(amount)` - Modify speed (called by acceleration controller)

**Physics Model:**
- Custom 2D isometric physics (gravity disabled in project settings)
- Speed-based velocity: `velocity = direction * current_speed`
- Collision detection using Godot's `move_and_collide()`
- Road gravity effects applied based on `current_gravity` value

---

### 2. Component System

Components are Resource-based objects that modify bus behavior through modifiers and properties.

#### BusMaterial (lib/resources/BusMaterial.gd)

Defines the bus chassis material with weight and durability properties.

**Material Types:**
- STEEL (baseline 1.0 weight)
- ALUMINUM (0.7x weight)
- CARBON_FIBER (0.5x weight)
- TITANIUM (0.6x weight, strongest)
- WOOD (0.4x weight, weakest)
- CRYSTAL (exotic)
- DARK_MATTER (0.1x weight, max strength)

**Power Source Modifiers:**
Material properties vary by power source. For example:
- Steel + Steam: 1.2x weight multiplier
- Carbon Fiber + Battery: 0.5x weight, 0.95x durability
- Dark Matter + Alien: 0.07x weight, 2.25x durability

**Methods:**
- `get_material_properties()` - Returns base weight, strength, cost
- `get_weight_modifier(power_source)` - Calculate final weight with power source interactions
- `get_durability_modifier(power_source)` - Calculate durability with power source interactions

#### PowerSource (lib/resources/PowerSource.gd)

Manages fuel and special properties for exotic power types.

**Source Types:**
- STEAM - Classic steampunk style
- GAS - Standard gasoline (default)
- HYDROGEN - Clean energy
- BATTERY - Electric
- ALIEN - Anti-gravity effects
- PSYCHIC - Mind-based power, affected by driver mood
- CHAOS - Unstable, random effects

**Properties:**
- `fuel_capacity`, `current_fuel`, `refuel_rate`
- Special properties: `psychic_resonance`, `chaos_stability`, `alien_core_health`

**Methods:**
- `get_special_effects()` - Returns particle effects, sound, and special behavior for power type
- `update_special_properties(delta, driver_mood)` - Update exotic properties over time

#### Other Components

**PassengerSection**: Manages passenger count and capacity
**TireMaterial**: Handles traction and braking characteristics
**EnginePower**: Determines acceleration and max speed
**RoadPointData**: Stores point-specific road properties (gravity, health, pollution, sewer)

---

### 3. Controller System

Controllers implement the MVC pattern, separating input handling, vehicle physics calculations, and steering logic.

#### Architecture Hierarchy

```
PlayerController (Input Management)
    ↓
Driver (Input State)
    ↓
VehicleController (Orchestrates vehicle updates)
    ├─ VehicleAccelerationController (Speed calculation)
    └─ VehicleSteeringController (Direction rotation)

    ↓
GameVehicle (Physics & Movement)
```

#### PlayerController (lib/controllers/driver/PlayerController.gd)

Reads keyboard/gamepad input and updates Driver state.

**Input Mappings:**
- `accelerate` → driver.accelerating (0-100)
- `steer_left` / `steer_right` → driver.steering (0-100, centered at 50)
- `brake` → driver.stopping (0-100)

#### Driver (lib/Driver.gd)

Simple state container holding current input values.

**Properties:**
- `accelerating: int` - Acceleration input (0-100)
- `steering: int` - Steering input (0-100)
- `stopping: int` - Brake input (0-100)

#### VehicleController (lib/controllers/VehicleController.gd)

Master orchestrator that combines acceleration and steering controllers.

**Update Flow:**
1. Calls acceleration controller to modify vehicle speed
2. Calls steering controller to rotate vehicle direction
3. Calls `move_and_collide()` to apply physics
4. Handles collision impacts through acceleration controller

#### VehicleAccelerationController (lib/controllers/VehicleAccelerationController.gd)

Base class for acceleration logic. Override in subclasses.

**VehicleAccelerationDefaultController** Implementation:

Constants:
- `acceleration = 100.0` - Speed gain per frame when accelerating
- `deceleration = -100.0` - Speed loss per frame when braking
- `stop = 10` - Passive friction/drag per frame

**Speed Calculation:**
1. Determine base amount (stop, acceleration, or deceleration)
2. Clamp result between `-effective_max_speed` and `effective_max_speed`
3. Call `vehicle.change_speed(amount)` to apply

**Collision Response:**
- Speed is reversed with `75%` dampening
- Direction and magnitude depend on impact factor (velocity / max_speed)

#### VehicleSteeringController (lib/controllers/VehicleSteeringController.gd)

Base class for steering logic. Override in subclasses.

**VehicleSteeringDefaultController** Implementation:

Constants:
- `_turn_amount = 2.0` - Radians per second turning rate

**Steering:**
- `steering == 50` (center): No rotation
- `steering < 50` (left): Rotate left (delta = -2.0)
- `steering > 50` (right): Rotate right (delta = 2.0)
- Call `vehicle.direct()` with rotated direction

**Initialization:**
- Maps 8 directional enum values (EAST, SOUTHEAST, SOUTH, etc.) to radians
- Accounts for isometric angle offset
- Sets initial vehicle direction

---

### 4. Level System

#### BusLevel (lib/BusLevel.gd)

Container for level data, currently minimal.

**Properties:**
- `map: TileMapLayer` - Reference to tile map

#### IsometricRoad (lib/isometricRoad.gd)

Advanced road generation tool with isometric-aligned drawing and property system. Extends `Line2D` with `@tool` decorator for editor functionality.

**Road Visual Properties:**
- `road_width` - Thickness of road line
- `road_color` - RGB color
- `sidewalk_width`, `sidewalk_color` - Optional sidewalk rendering
- `center_line_color`, `center_line_dashed` - Road markings

**Isometric Configuration:**
- `snap_to_isometric` - Auto-snap points to isometric grid
- `isometric_angle` - Grid angle (default 26.565°)
- `grid_size` - Snap grid unit size (default 32.0)

**Point Properties System:**
Each road point stores `RoadPointData`:
- `gravity` - Affects bus acceleration on this segment
- `health` - Road condition (affects vehicle damage)
- `pollution` - Environmental property
- `sewer_percent` - Infrastructure property

**Property Visualization:**
- `visualize_properties` - Show gradient colors along road
- `property_to_visualize` - Select which property to display
- Colors map: Green→Red (gravity), Red→Green (health), Green→Purple (pollution)

**Key Methods:**
- `snap_to_isometric_grid(point)` - Convert point to isometric grid coordinates
- `get_properties_at_position(world_pos)` - Return interpolated RoadPointData for a position
- `get_gravity_at_position(world_pos)` - Get gravity effect at position
- `interpolate_point_data(data1, data2, t)` - Smooth property transitions
- `update_sidewalks()` - Rebuild sidewalk Line2D
- `update_markings()` - Rebuild center line (solid or dashed)
- `update_road_geometry()` - Render end caps for isometric alignment

**Drawing Helpers (Editor Only):**
- `draw_isometric_grid()` - Show isometric grid overlay
- `draw_point_handle(index)` - Show directional arrows at each point
- `show_direction_handles` - Visualize isometric axes
- `show_grid` - Display background grid

**Collision Detection:**
Uses distance-to-line algorithm to find closest road segment and interpolate properties smoothly.

---

### 5. Input System

**Input Actions (project.godot):**
- `accelerate` - W / Up arrow
- `brake` - S / Down arrow
- `steer_left` - A / Left arrow
- `steer_right` - D / Right arrow

**Flow:**
1. PlayerController reads Input state each frame
2. Updates Driver object with current input values
3. VehicleController uses Driver state to calculate movement
4. Movement applied to GameVehicle

---

## Data Flow

### Update Loop (per frame)

```
city._process(delta)
  ├─ PlayerController.update(driver)
  │   └─ Read Input actions → Update driver state
  │
  └─ VehicleController.update(vehicle, driver)
      ├─ VehicleAccelerationController.accelerate(vehicle, driver)
      │   └─ Calculate new speed based on driver input
      │
      ├─ VehicleSteeringController.steer(driver, vehicle)
      │   └─ Rotate direction based on steering input
      │
      └─ VehicleController._apply_movement(vehicle)
          ├─ vehicle.move_and_collide(velocity * delta)
          │   └─ Apply physics and detect collisions
          │
          └─ VehicleAccelerationController.apply_collision_impact()
              └─ Bounce back with dampening
```

### Road Interaction

```
GameVehicle Physics
  ├─ Check road properties (if check_road_properties = true)
  │   └─ IsometricRoad.get_gravity_at_position(vehicle_position)
  │       └─ Current gravity affects acceleration
  │
  └─ Apply gravity effect
      └─ current_gravity * gravity_effect_multiplier
```

---

## Isometric Projection

### Coordinate System

Bus Wars uses a 2D isometric projection with:
- **Isometric Angle**: 26.565° (standard isometric)
- **Grid Unit**: 32.0 pixels
- **Tile Size**: 64×32 pixels (width × height)

### Vehicle Positioning

The `GameVehicle` class maintains:
- **world position** - Absolute 2D coordinates
- **visual rotation** - Display angle for sprite rotation
- **direction** - Normalized direction vector
- **movement_angle** - Angle of motion (in radians)

### Direction Enumeration

8 cardinal directions for initialization:
- EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST, NORTH, NORTHEAST

Each maps to a specific starting angle accounting for isometric perspective.

---

## Physics Model

### Speed-Based Movement

Rather than force-based physics, Bus Wars uses **speed scalars**:

1. `current_speed` - Signed scalar (positive = forward, negative = backward)
2. `direction` - Unit vector (changes only through steering)
3. `velocity = direction * current_speed`
4. Movement: `position += velocity * delta_time`

### Acceleration Model

**Default Controller:**
- Accelerating: +100 units/frame
- Braking: -100 units/frame
- Passive drag: ±10 units/frame (toward 0)
- Max speed clamping

### Steering Model

- Turn rate: 2.0 radians/second
- Rotation applied to direction vector
- No acceleration-based turning (steering is independent)

---

## Extensibility

### Adding New Controller Types

1. Extend `VehicleAccelerationController` or `VehicleSteeringController`
2. Override `accelerate()` or `steer()` methods
3. In `city._process()`, instantiate your controller:
   ```gdscript
   _vehicle_controller = VehicleController.new(
       MyCustomAccelerationController.new(),
       MyCustomSteeringController.new()
   )
   ```

### Adding Custom Road Properties

1. Extend `RoadPointData` with new fields
2. Update `IsometricRoad.get_property_color()` for visualization
3. Update `IsometricRoad.get_interpolated_property()` for lerping
4. Access via `road.get_properties_at_position(position)`

### Adding Component Types

1. Create new Resource class extending GDScript Resource
2. Export from `GameVehicle`
3. Implement modifier methods (e.g., `get_weight_modifier()`)
4. Access in controllers via `vehicle.component_name`

---

## File Structure

```
lib/
├─ GameVehicle.gd                          # Main vehicle class
├─ Driver.gd                                # Input state container
├─ BusLevel.gd                              # Level data container
├─ isometricRoad.gd                         # Road with properties
├─ road.gd                                  # Basic road class
├─ city.gd                                  # Main level/game controller
├─ LevelController.gd                       # Level management
├─ BusDebugUI.gd                            # Debug overlay
├─ BusDebugVectors.gd                       # Physics visualization
├─ TileSetGenerator.gd                      # Editor tool
├─ camera_2d.gd                             # Camera control
│
├─ resources/
│   ├─ BusMaterial.gd                       # Material properties
│   ├─ PassengerSection.gd                  # Capacity management
│   ├─ TireMaterial.gd                      # Traction properties
│   ├─ EnginePower.gd                       # Speed modifiers
│   ├─ PowerSource.gd                       # Fuel & special effects
│   └─ RoadPointData.gd                     # Per-point road data
│
├─ controllers/
│   ├─ VehicleController.gd                 # Master orchestrator
│   ├─ VehicleAccelerationController.gd     # Base acceleration class
│   ├─ VehicleSteeringController.gd         # Base steering class
│   │
│   ├─ driver/
│   │   └─ PlayerController.gd              # Input reading
│   │
│   └─ vehicle/
│       ├─ acceleration/
│       │   └─ DefaultController.gd         # Default acceleration impl
│       │
│       └─ steering/
│           └─ DefaultController.gd         # Default steering impl
│
├─ factories/
│   └─ PowerSourceFactory.gd                # Power source creation
│
scenes/
├─ levels/
│   ├─ isometricRoad.tscn                   # Road scene
│   └─ tile_map_layer.tscn                  # Tile map
│
└─ player/
    └─ Bus.tscn                             # Player bus scene

assets/                                      # Sprites, audio, etc.
shaders/                                     # GLSL shaders
```

---

## Design Patterns

### 1. Component Pattern
Bus properties determined by pluggable Resource objects (Material, Engine, etc.)

### 2. Controller Pattern
Separation of concerns: Input (PlayerController) → State (Driver) → Logic (VehicleController) → Physics (GameVehicle)

### 3. Strategy Pattern
Acceleration/steering controllers can be swapped at runtime for different vehicle behaviors

### 4. Tool Scripts
IsometricRoad uses `@tool` decorator to provide editor-only functionality while maintaining runtime behavior

### 5. Resource-Based Architecture
Buses built from Godot Resources, enabling save/load and data-driven design

---

## Performance Considerations

1. **Physics**: Simple speed scalar model is faster than force-based simulation
2. **Road Properties**: Interpolation only calculated on road collision/position change
3. **Isometric Grid**: Snapping only occurs when editing or on point addition
4. **Debug Rendering**: All debug features optional and disabled by default
5. **Collision**: Uses Godot's native CharacterBody2D collision handling

---

## Future Expansion Points

1. **AI Drivers**: Extend PlayerController with AI implementations
2. **Route System**: Pathfinding between bus stops using road graph
3. **Passenger AI**: Spawn and manage NPC passengers
4. **Economy**: Fare collection, company competition
5. **Upgrades**: Unlock new materials, engines, power sources
6. **Multiplayer**: Network-based bus routing competition
7. **Visual Novel System**: Story dialogue and branching paths
