extends CharacterBody2D
class_name GameVehicle

# Component Resources
@export_group("Bus Components")
@export var bus_material: BusMaterial
@export var passenger_section: PassengerSection
@export var tires: TireMaterial
@export var engine: EnginePower
@export var power_source: PowerSource

# Movement settings
@export_group("Movement Settings")
@export var base_max_speed: float = 300.0
@export var base_friction: float = 400.0

# Isometric settings
@export_group("Isometric Settings")
@export var bus_level: BusLevel
@export var tilemap_layer_path: NodePath
@export var override_angle: float = -1.0
@export var override_tile_size: Vector2 = Vector2.ZERO

# Road interaction
@export_group("Road Interaction")
@export var check_road_properties: bool = true
@export var gravity_effect_multiplier: float = 1.0

# Debug settings
@export_group("Debug UI")
@export var show_debug_info: bool = true
@export var show_component_stats: bool = false

# Initial direction
enum StartDirection { EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST, NORTH, NORTHEAST }
@export var start_direction: StartDirection = StartDirection.EAST
@export var direction: Vector2

# Auto-detected values
var isometric_angle: float = 26.565
var tile_size: Vector2 = Vector2(64, 32)
var tilemap_layer: TileMapLayer

# Current movement state
var current_speed: float = 0.0
var visual_rotation: float = 0.0
var movement_angle: float = 0.0

# Current road data
var current_road = null
var current_gravity: int = 50

# Calculated properties
var total_weight: float = 1000.0
var effective_max_speed: float = 300.0

var stopping: bool = false

func _ready():
	# Initialize components if not set
	if not material:
		bus_material = BusMaterial.new()
	if not passenger_section:
		passenger_section = PassengerSection.new()
	if not tires:
		tires = TireMaterial.new()
	if not engine:
		engine = EnginePower.new()
	if not power_source:
		power_source = PowerSource.new()
	
	set_physics_process(true)

# Public methods for game systems
func add_passengers_at_stop(count: int) -> int:
	return passenger_section.add_passengers(count)

func remove_passengers_at_stop(count: int) -> int:
	return passenger_section.remove_passengers(count)

func refuel_bus(delta: float):
	power_source.refuel(delta)

func stop():
	stopping = true

func not_stop():
	stopping = false

func direct(new_direction: Vector2):
	direction = new_direction
	movement_angle = direction.angle()
	rotation = movement_angle
	visual_rotation = movement_angle

func change_speed(amount: float):
	current_speed += amount * get_process_delta_time()
	velocity = direction * current_speed
