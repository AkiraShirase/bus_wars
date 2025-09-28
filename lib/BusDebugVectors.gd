# BusDebugVectors.gd
extends Node2D
class_name BusDebugVectors

# Vector visualization settings
@export_group("Vector Display")
@export var show_velocity_vector: bool = true
@export var show_direction_vector: bool = true
@export var show_movement_vector: bool = true
@export var vector_scale: float = 0.6

# Vector colors
@export_group("Vector Colors")
@export var velocity_color: Color = Color.GREEN
@export var direction_color: Color = Color.BLUE
@export var movement_color: Color = Color.YELLOW

# UI Window
@export_group("Debug UI")
@export var use_ui_window: bool = true
@export var ui_window_scene: PackedScene = null

# Reference to the bus
@export var bus: GameVehicle
var debug_ui: BusDebugUI = null

# Cached values for smooth display
var smooth_velocity: Vector2 = Vector2.ZERO
var smooth_speed: float = 0.0

func _ready():
	# Try to find parent bus
	var parent = get_parent()
	if parent is GameVehicle:
		bus = parent
		# Add bus to group for easier finding
		bus.add_to_group("buses")
	else:
		push_warning("BusDebugVectors should be a child of Bus node!")
	
	# Set to top of rendering for vectors
	z_index = 100
	
	# Create UI window if enabled
	if use_ui_window:
		create_debug_ui()

func create_debug_ui():
	# Check if UI already exists
	var canvas_layer = get_tree().get_root().find_child("DebugCanvasLayer", false, false)
	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		canvas_layer.name = "DebugCanvasLayer"
		canvas_layer.layer = 128  # High layer for UI
		get_tree().get_root().add_child(canvas_layer)
	
	# Create UI from scene or default
	if ui_window_scene:
		var instance = ui_window_scene.instantiate()
		if instance is BusDebugUI:
			debug_ui = instance
			canvas_layer.add_child(debug_ui)
			debug_ui.set_bus(bus)
	else:
		# Create default UI
		debug_ui = BusDebugUI.new()
		debug_ui.set_bus(bus)
		# Ensure it starts in top right corner
		debug_ui.margin = Vector2(10, 10)
		canvas_layer.add_child(debug_ui)

func _draw():
	if not bus:
		return
	
	# Only draw vectors, UI handles the info display
	if show_velocity_vector or show_direction_vector or show_movement_vector:
		draw_vectors()

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

# Update smooth values
func _process(delta):
	if not bus:
		return
	
	# Smooth velocity for display
	smooth_velocity = smooth_velocity.lerp(bus.velocity, bus.get_process_delta_time() * 10.0)
	smooth_speed = lerp(smooth_speed, bus.velocity.length(), delta * 10.0)
	
	# Request redraw for vectors
	queue_redraw()

# Public methods
func toggle_ui():
	if debug_ui:
		debug_ui.visible = !debug_ui.visible

func set_ui_position(pos: Vector2):
	if debug_ui:
		debug_ui.position = pos

func toggle_vectors(vector_type: String):
	match vector_type:
		"velocity":
			show_velocity_vector = !show_velocity_vector
		"direction":
			show_direction_vector = !show_direction_vector
		"movement":
			show_movement_vector = !show_movement_vector

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
	debug.use_ui_window = true
	return debug

static func create_full():
	var debug = new()
	debug.name = "DebugVectors"
	debug.show_velocity_vector = true
	debug.show_direction_vector = true
	debug.show_movement_vector = true
	debug.use_ui_window = true
	return debug
