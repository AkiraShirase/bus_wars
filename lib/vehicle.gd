extends CharacterBody2D
class_name Vehicle

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
	
	# Calculate initial properties
	update_bus_properties()
	
	set_physics_process(true)

func _physics_process(delta):
	# Update components
	update_components(delta)
	
	# Update road properties
	if check_road_properties:
		update_current_road()
	
	# Handle input and movement
	handle_input(delta)
	apply_movement(delta)
	move_and_slide()
	
	# Update visual rotation
	rotation = visual_rotation
	
	# Update debug display
	if show_debug_info:
		queue_redraw()

func update_components(delta):
	# Update tire wear and temperature
	tires.update_wear(delta, current_speed, 0.0)
	tires.update_temperature(delta, current_speed)
	
	# Update engine
	engine.update_rpm(current_speed)
	engine.update_temperature(delta, 0.0)
	
	# Update passenger satisfaction
	passenger_section.update_satisfaction(delta, current_speed, 0.0)
	
	# Update special power source properties
	power_source.update_special_properties(delta)
	
	# Consume fuel
	var fuel_consumption = engine.calculate_fuel_consumption(power_source.get_source_name(), 0.0)
	if not power_source.consume_fuel(fuel_consumption, delta):
		# Out of fuel!

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

func handle_input(delta):
	# Update bus properties based on current state
	update_bus_properties()
	

func apply_movement(delta):
	# Calculate movement direction
	var direction = Vector2.RIGHT.rotated(movement_angle)
	
	# Apply velocity
	velocity = direction * current_speed
	
	# Apply special power source movement effects
	match power_source.source_type:
		PowerSource.SourceType.ALIEN:
			# Slight hover effect - reduced friction
			velocity *= 1.0 + (power_source.alien_core_health / 100.0) * 0.2
		PowerSource.SourceType.CHAOS:
			# Random velocity fluctuations
			velocity *= randf_range(0.9, 1.1)
	
	# Smooth the movement angle toward visual rotation
	if abs(current_speed) > 10:
		movement_angle = lerp_angle(movement_angle, visual_rotation, 0.1)

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

func update_current_road():
	var roads = get_tree().get_nodes_in_group("roads")
	
	current_road = null
	var min_distance = INF
	
	for road in roads:
		if road.has_method("get_gravity_at_position"):
			var local_pos = road.to_local(global_position)
			
			for i in range(road.points.size() - 1):
				var closest = get_closest_point_on_line(local_pos, road.points[i], road.points[i + 1])
				var dist = local_pos.distance_to(closest)
				
				if dist < road.road_width / 2 + 10 and dist < min_distance:
					min_distance = dist
					current_road = road
	
	if current_road and current_road.has_method("get_gravity_at_position"):
		current_gravity = current_road.get_gravity_at_position(global_position)
	else:
		current_gravity = 50

func get_closest_point_on_line(point: Vector2, line_start: Vector2, line_end: Vector2) -> Vector2:
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_len = line_vec.length()
	
	if line_len == 0:
		return line_start
	
	var line_unitvec = line_vec / line_len
	var proj_length = clamp(point_vec.dot(line_unitvec), 0.0, line_len)
	
	return line_start + line_unitvec * proj_length

func world_to_isometric(world_pos: Vector2) -> Vector2:
	var iso_x = world_pos.x / tile_size.x + world_pos.y / tile_size.y
	var iso_y = world_pos.y / tile_size.y - world_pos.x / tile_size.x
	return Vector2(iso_x, iso_y)

func get_tile_position() -> Vector2i:
	var iso_pos = world_to_isometric(global_position)
	return Vector2i(round(iso_pos.x), round(iso_pos.y))

func _draw():
	if not show_debug_info:
		return
	
	var font = ThemeDB.fallback_font
	var y_offset = -60
	
	# Basic info
	draw_string(font, Vector2(20, y_offset), "Speed: %d km/h" % int(current_speed * 3.6), 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	
	y_offset -= 20
	draw_string(font, Vector2(20, y_offset), "Fuel: %d%%" % int((power_source.current_fuel / power_source.fuel_capacity) * 100), 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.YELLOW)
	
	y_offset -= 20
	draw_string(font, Vector2(20, y_offset), "Passengers: %d/%d" % [passenger_section.current_passengers, passenger_section.get_total_capacity()], 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.CYAN)
	
	if check_road_properties and current_gravity != 50:
		y_offset -= 20
		var gravity_color = Color.GREEN if current_gravity < 50 else Color.RED
		draw_string(font, Vector2(20, y_offset), "Gravity: %d" % current_gravity, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, gravity_color)
	
	# Component stats
	if show_component_stats:
		y_offset -= 30
		draw_string(font, Vector2(20, y_offset), "=== Components ===", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.GRAY)
		
		y_offset -= 18
		draw_string(font, Vector2(20, y_offset), "Power: %s" % power_source.get_source_name(), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.GREEN)
		
		y_offset -= 18
		draw_string(font, Vector2(20, y_offset), "Tire Wear: %d%%" % int(tires.wear_level), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.ORANGE)
		
		y_offset -= 18
		draw_string(font, Vector2(20, y_offset), "Engine Temp: %d°C" % int(engine.temperature), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.RED if engine.temperature > 100 else Color.WHITE)
		
		y_offset -= 18
		draw_string(font, Vector2(20, y_offset), "Weight: %d kg" % int(total_weight), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.GRAY)

# Public methods for game systems
func add_passengers_at_stop(count: int) -> int:
	return passenger_section.add_passengers(count)

func remove_passengers_at_stop(count: int) -> int:
	return passenger_section.remove_passengers(count)

func refuel_bus(delta: float):
	power_source.refuel(delta)

func repair_tires():
	tires.wear_level = 100.0
	tires.temperature = 20.0
