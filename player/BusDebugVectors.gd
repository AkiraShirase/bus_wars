# BusDebugVectors.gd
extends Node2D
class_name BusDebugVectors

# Vector visualization settings
@export_group("Vector Display")
@export var show_velocity_vector: bool = true
@export var show_direction_vector: bool = true
@export var show_movement_vector: bool = true
@export var vector_scale: float = 1.0

# Vector colors
@export_group("Vector Colors")
@export var velocity_color: Color = Color.GREEN
@export var direction_color: Color = Color.BLUE
@export var movement_color: Color = Color.YELLOW

# Info display settings
@export_group("Info Display")
@export var show_speed: bool = true
@export var show_tile_position: bool = true
@export var show_gravity: bool = true
@export var show_component_stats: bool = false
@export var info_background: bool = true
@export var info_background_color: Color = Color(0, 0, 0, 0.7)

# Reference to the bus
var bus: Bus = null

# Cached values for smooth display
var smooth_velocity: Vector2 = Vector2.ZERO
var smooth_speed: float = 0.0

func _ready():
	# Try to find parent bus
	var parent = get_parent()
	if parent is Bus:
		bus = parent
	else:
		push_warning("BusDebugVectors should be a child of Bus node!")
	
	# Set to top of rendering
	z_index = 100

func _draw():
	if not bus:
		return
	
	# Draw vectors
	if show_velocity_vector or show_direction_vector or show_movement_vector:
		draw_vectors()
	
	# Draw info panel
	draw_info_panel()

func draw_vectors():
	var bus_rotation = bus.rotation
	
	# Velocity vector (GREEN) - where we're actually moving
	if show_velocity_vector and bus.velocity.length() > 0:
		var local_velocity = bus.velocity.rotated(-bus_rotation) * vector_scale
		draw_line(Vector2.ZERO, local_velocity, velocity_color, 3.0)
		draw_circle(local_velocity, 5, velocity_color)
		
		# Draw speed value at vector tip
		var speed_text = "%d" % int(bus.velocity.length())
		var font = ThemeDB.fallback_font
		draw_string(font, local_velocity + Vector2(10, -5), speed_text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, velocity_color)
	
	# Direction vector (BLUE) - where we're facing
	if show_direction_vector:
		var facing_direction = Vector2.RIGHT * 100 * vector_scale
		draw_line(Vector2.ZERO, facing_direction, direction_color, 2.0)
		draw_circle(facing_direction, 4, direction_color)
	
	# Movement angle vector (YELLOW) - actual movement angle (shows drift)
	if show_movement_vector and abs(bus.movement_angle - bus.visual_rotation) > 0.01:
		var move_dir_world = Vector2.RIGHT.rotated(bus.movement_angle)
		var move_dir_local = move_dir_world.rotated(-bus_rotation) * 80 * vector_scale
		draw_line(Vector2.ZERO, move_dir_local, movement_color, 1.0)
		draw_circle(move_dir_local, 3, movement_color)

func draw_info_panel():
	var font = ThemeDB.fallback_font
	var line_height = 20
	var padding = 10
	var panel_width = 250
	var start_y = -80
	
	# Calculate panel height based on enabled options
	var line_count = 0
	if show_speed: line_count += 1
	if show_tile_position: line_count += 1
	if show_gravity and bus.check_road_properties: line_count += 1
	if show_component_stats: line_count += 7
	
	var panel_height = line_count * line_height + padding * 2
	
	# Draw background panel
	if info_background and line_count > 0:
		var panel_rect = Rect2(
			Vector2(15, start_y - padding),
			Vector2(panel_width, panel_height)
		)
		draw_rect(panel_rect, info_background_color)
		draw_rect(panel_rect, Color.WHITE, false, 1.0)
	
	# Draw info text
	var y_offset = start_y
	
	if show_speed:
		var speed_kmh = int(bus.current_speed * 3.6)
		var speed_color = Color.WHITE
		if speed_kmh > 80:
			speed_color = Color.YELLOW
		elif speed_kmh > 120:
			speed_color = Color.RED
		
		draw_string(font, Vector2(20, y_offset), "Speed: %d km/h" % speed_kmh,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, speed_color)
		y_offset += line_height
	
	if show_tile_position:
		var tile_pos = bus.get_tile_position()
		draw_string(font, Vector2(20, y_offset), "Tile: [%d, %d]" % [tile_pos.x, tile_pos.y],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.CYAN)
		y_offset += line_height
	
	if show_gravity and bus.check_road_properties and bus.current_gravity != 50:
		var gravity_color = Color.WHITE
		var gravity_text = "Gravity: %d" % bus.current_gravity
		
		if bus.current_gravity < 40:
			gravity_color = Color.GREEN
			gravity_text += " ↓"  # Downhill
		elif bus.current_gravity > 60:
			gravity_color = Color.RED
			gravity_text += " ↑"  # Uphill
		
		draw_string(font, Vector2(20, y_offset), gravity_text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, gravity_color)
		y_offset += line_height
	
	if show_component_stats:
		y_offset += 10  # Extra spacing
		draw_string(font, Vector2(20, y_offset), "=== Components ===",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.GRAY)
		y_offset += line_height
		
		# Power source
		var power_name = bus.power_source.get_source_name().capitalize()
		var fuel_percent = int((bus.power_source.current_fuel / bus.power_source.fuel_capacity) * 100)
		draw_string(font, Vector2(20, y_offset), "Power: %s (%d%%)" % [power_name, fuel_percent],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.GREEN)
		y_offset += line_height
		
		# Tire wear
		var tire_color = Color.GREEN
		if bus.tires.wear_level < 30:
			tire_color = Color.RED
		elif bus.tires.wear_level < 60:
			tire_color = Color.YELLOW
		
		draw_string(font, Vector2(20, y_offset), "Tire Wear: %d%%" % int(bus.tires.wear_level),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, tire_color)
		y_offset += line_height
		
		# Engine temperature
		var temp_color = Color.WHITE
		if bus.engine.temperature > 100:
			temp_color = Color.RED
		elif bus.engine.temperature > 80:
			temp_color = Color.YELLOW
		
		draw_string(font, Vector2(20, y_offset), "Engine: %d°C" % int(bus.engine.temperature),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, temp_color)
		y_offset += line_height
		
		# Weight
		draw_string(font, Vector2(20, y_offset), "Weight: %d kg" % int(bus.total_weight),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.GRAY)
		y_offset += line_height
		
		# Passengers
		var passenger_ratio = float(bus.passenger_section.current_passengers) / float(bus.passenger_section.get_total_capacity())
		var passenger_color = Color.GREEN
		if passenger_ratio > 0.9:
			passenger_color = Color.RED
		elif passenger_ratio > 0.7:
			passenger_color = Color.YELLOW
		
		draw_string(font, Vector2(20, y_offset), "Passengers: %d/%d" % [
			bus.passenger_section.current_passengers,
			bus.passenger_section.get_total_capacity()
		], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, passenger_color)
		y_offset += line_height
		
		# Special power source info
		draw_special_power_info(y_offset)

func draw_special_power_info(y_offset: float):
	var font = ThemeDB.fallback_font
	
	match bus.power_source.source_type:
		PowerSource.SourceType.PSYCHIC:
			var resonance_color = Color.PURPLE.lerp(Color.CYAN, bus.power_source.psychic_resonance)
			draw_string(font, Vector2(20, y_offset), "Psychic: %d%%" % int(bus.power_source.psychic_resonance * 100),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 14, resonance_color)
		
		PowerSource.SourceType.ALIEN:
			var core_color = Color.GREEN if bus.power_source.alien_core_health > 50 else Color.RED
			draw_string(font, Vector2(20, y_offset), "Core: %d%%" % int(bus.power_source.alien_core_health),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 14, core_color)
		
		PowerSource.SourceType.CHAOS:
			var chaos_color = Color(
				randf_range(0.5, 1.0),
				randf_range(0.5, 1.0),
				randf_range(0.5, 1.0)
			)
			draw_string(font, Vector2(20, y_offset), "Chaos: %d%%" % int(bus.power_source.chaos_stability * 100),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 14, chaos_color)

# Update smooth values
func _process(delta):
	if not bus:
		return
	
	# Smooth velocity for display
	smooth_velocity = smooth_velocity.lerp(bus.velocity, delta * 10.0)
	smooth_speed = lerp(smooth_speed, bus.velocity.length(), delta * 10.0)
	
	# Request redraw
	queue_redraw()

# Helper to create preset configurations
static func create_default():
	var debug = new()
	debug.name = "DebugVectors"
	return debug

static func create_minimal():
	var debug = new()
	debug.name = "DebugVectors"
	debug.show_velocity_vector = true
	debug.show_direction_vector = false
	debug.show_movement_vector = false
	debug.show_tile_position = false
	debug.show_gravity = true
	debug.show_component_stats = false
	return debug

static func create_full():
	var debug = new()
	debug.name = "DebugVectors"
	debug.show_velocity_vector = true
	debug.show_direction_vector = true
	debug.show_movement_vector = true
	debug.show_speed = true
	debug.show_tile_position = true
	debug.show_gravity = true
	debug.show_component_stats = true
	return debug
