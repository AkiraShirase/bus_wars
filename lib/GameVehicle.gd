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
	
	# Setup tilemap
	setup_from_tilemap()
	
	# Initialize direction
	set_initial_direction()
	
	set_physics_process(true)

func _physics_process(delta):
	_apply_movement(delta)
	move_and_slide()

func update_bus_properties():
	# Calculate total weight
	var material_weight_mod = bus_material.get_weight_modifier(power_source.get_source_name())
	var base_bus_weight = 5000.0 * material_weight_mod
	var passenger_weight = passenger_section.get_total_weight()
	var component_weights = power_source.get_properties()["weight"] + 200.0  # Tires and misc
	
	total_weight = base_bus_weight + passenger_weight + component_weights
	
	# Calculate effective acceleration
	var power = engine.get_current_power(power_source.get_source_name(), 1.0)
	var tire_grip = tires.get_acceleration_modifier()
	
	# Calculate effective max speed
	var speed_rating = tires.get_tire_properties()["speed_rating"]
	effective_max_speed = base_max_speed * speed_rating * (power / 200.0)
	
	# Calculate turn speed based on tire stability
	

func _apply_movement(delta):
	velocity = direction * current_speed
	rotation = visual_rotation

func setup_from_tilemap():
	# Get tilemap information
	if tilemap_layer_path:
		tilemap_layer = get_node(tilemap_layer_path)
	else:
		tilemap_layer = find_tilemap_in_scene()
	
	if not tilemap_layer:
		push_warning("No TileMapLayer found! Using default isometric values.")
		return
	
	# Get tile set information
	var tileset = tilemap_layer.tile_set
	if not tileset:
		push_warning("TileMapLayer has no TileSet! Using default values.")
		return
	
	# Extract tile shape and size
	var tile_shape = tileset.tile_shape
	var extracted_tile_size = tileset.tile_size
	
	# Check if using override values
	if override_tile_size != Vector2.ZERO:
		tile_size = override_tile_size
	else:
		tile_size = extracted_tile_size
	
	# Determine angle based on tile shape and layout
	if tile_shape == TileSet.TILE_SHAPE_ISOMETRIC:
		if override_angle >= 0:
			isometric_angle = override_angle
		else:
			var ratio = float(tile_size.y) / float(tile_size.x)
			isometric_angle = rad_to_deg(atan(ratio))
		
		print("Isometric tilemap detected!")
		print("  Tile size: ", tile_size)
		print("  Isometric angle: ", isometric_angle, "°")

func find_tilemap_in_scene() -> TileMapLayer:
	var current = get_parent()
	while current:
		for child in current.get_children():
			if child is TileMapLayer:
				return child
			if child is TileMap:
				return child
		current = current.get_parent()
	return null

func set_initial_direction():
	var direction_angles = {
		StartDirection.EAST: 0 + isometric_angle,
		StartDirection.SOUTHEAST: 45 + isometric_angle,
		StartDirection.SOUTH: 90 + isometric_angle,
		StartDirection.SOUTHWEST: 135 + isometric_angle,
		StartDirection.WEST: 180 + isometric_angle,
		StartDirection.NORTHWEST: 225 + isometric_angle,
		StartDirection.NORTH: 270 + isometric_angle,
		StartDirection.NORTHEAST: 315 + isometric_angle
	}
	
	var initial_angle_deg = direction_angles[start_direction]
	visual_rotation = deg_to_rad(initial_angle_deg)
	rotation = visual_rotation
	movement_angle = visual_rotation
	direction = Vector2.RIGHT.rotated(movement_angle)

func world_to_isometric(world_pos: Vector2) -> Vector2:
	var iso_x = world_pos.x / tile_size.x + world_pos.y / tile_size.y
	var iso_y = world_pos.y / tile_size.y - world_pos.x / tile_size.x
	return Vector2(iso_x, iso_y)

func get_tile_position() -> Vector2i:
	var iso_pos = world_to_isometric(global_position)
	return Vector2i(round(iso_pos.x), round(iso_pos.y))

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

func direct(new_direction: float):
	direction = direction.rotated(new_direction * get_process_delta_time())
	movement_angle = direction.angle()

func steer(new_direction: float):
	visual_rotation = new_direction

func change_speed(amount: float):
	current_speed += amount * get_process_delta_time()	
