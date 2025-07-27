extends CharacterBody2D

# Movement variables
@export var max_speed: float = 300.0
@export var acceleration: float = 500.0
@export var friction: float = 400.0
@export var turn_speed: float = 2.0  # Radians per second
@export var brake_strength: float = 800.0  # Stronger than friction

# Initial direction
enum StartDirection { EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST, NORTH, NORTHEAST }
@export var start_direction: StartDirection = StartDirection.EAST

# Isometric settings
@export var tilemap_layer_path: NodePath  # Path to your TileMapLayer
@export var override_angle: float = -1.0  # Set to override auto-detection
@export var override_tile_size: Vector2 = Vector2.ZERO  # Set to override auto-detection

# Auto-detected values
var isometric_angle: float = 26.565  # Will be set from tilemap
var tile_size: Vector2 = Vector2(64, 32)  # Will be set from tilemap
var tilemap_layer: TileMapLayer

# Debug visualization
@export var show_debug_vectors: bool = true
@export var vector_scale: float = 1.0
@export var velocity_color: Color = Color.GREEN
@export var direction_color: Color = Color.BLUE
@export var show_tile_position: bool = true

# Current movement state
var current_speed: float = 0.0
var visual_rotation: float = 0.0  # The rotation we show
var movement_angle: float = 0.0   # The actual movement direction - will be set in _ready()

func _ready():
	# Get tilemap information
	setup_from_tilemap()
	
	# Initialize rotation based on selected start direction
	set_initial_direction()
	set_physics_process(true)

func set_initial_direction():
	# In isometric view, the axes are rotated by the isometric angle
	# East in isometric = screen right rotated by isometric angle
	var direction_angles = {
		StartDirection.EAST: 0 + isometric_angle,          # Right in iso grid
		StartDirection.SOUTHEAST: 45 + isometric_angle,    # Down-right in iso
		StartDirection.SOUTH: 90 + isometric_angle,        # Down in iso grid
		StartDirection.SOUTHWEST: 135 + isometric_angle,   # Down-left in iso
		StartDirection.WEST: 180 + isometric_angle,        # Left in iso grid
		StartDirection.NORTHWEST: 225 + isometric_angle,   # Up-left in iso
		StartDirection.NORTH: 270 + isometric_angle,       # Up in iso grid
		StartDirection.NORTHEAST: 315 + isometric_angle    # Up-right in iso
	}
	
	var initial_angle_deg = direction_angles[start_direction]
	visual_rotation = deg_to_rad(initial_angle_deg)
	rotation = visual_rotation
	movement_angle = visual_rotation
	
	print("Bus initialized facing: ", StartDirection.keys()[start_direction])
	print("Initial angle: ", initial_angle_deg, "°")

func setup_from_tilemap():
	# Get the TileMapLayer node
	if tilemap_layer_path:
		tilemap_layer = get_node(tilemap_layer_path)
	else:
		# Try to find it automatically in the scene
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
		# Calculate angle from tile dimensions
		if override_angle >= 0:
			isometric_angle = override_angle
		else:
			# Standard isometric angle calculation
			# For 2:1 ratio isometric tiles, the angle is atan(0.5) ≈ 26.565°
			var ratio = float(tile_size.y) / float(tile_size.x)
			isometric_angle = rad_to_deg(atan(ratio))
		
		print("Isometric tilemap detected!")
		print("  Tile size: ", tile_size)
		print("  Isometric angle: ", isometric_angle, "°")
		
		# Show the 8 cardinal directions for this isometric setup
		print("Cardinal directions for movement:")
		print("  East (Right): ", 0 + isometric_angle, "°")
		print("  Southeast: ", 45 + isometric_angle, "°")
		print("  South (Down): ", 90 + isometric_angle, "°")
		print("  Southwest: ", 135 + isometric_angle, "°")
		print("  West (Left): ", 180 + isometric_angle, "°")
		print("  Northwest: ", 225 + isometric_angle, "°")
		print("  North (Up): ", 270 + isometric_angle, "°")
		print("  Northeast: ", 315 + isometric_angle, "°")
	else:
		push_warning("TileMap is not isometric! Shape: ", tile_shape)

func find_tilemap_in_scene() -> TileMapLayer:
	# Search for TileMapLayer in parent nodes
	var current = get_parent()
	while current:
		for child in current.get_children():
			if child is TileMapLayer:
				return child
			# Also check TileMap node (which contains TileMapLayers)
			if child is TileMap:
				for layer_idx in child.get_layers_count():
					# In Godot 4.4, we work with the TileMap directly
					return child
		current = current.get_parent()
	return null

func _physics_process(delta):
	handle_input(delta)
	apply_movement(delta)
	move_and_slide()
	
	# Update visual rotation
	rotation = visual_rotation
	
	# Force redraw for debug vectors
	if show_debug_vectors:
		queue_redraw()

func handle_input(delta):
	# Forward/Backward movement
	var input_vertical = Input.get_axis("ui_down", "ui_up")  # up = forward, down = reverse
	
	# If starting from stop, align movement with visual direction
	if abs(current_speed) < 1.0 and input_vertical != 0:
		movement_angle = visual_rotation
	
	if input_vertical != 0:
		# Accelerate or reverse
		current_speed += input_vertical * acceleration * delta
		current_speed = clamp(current_speed, -max_speed * 0.5, max_speed)  # Reverse is slower
	else:
		# Apply friction when no input
		var friction_force = friction * delta
		if abs(current_speed) > friction_force:
			current_speed -= sign(current_speed) * friction_force
		else:
			current_speed = 0.0
	
	# Brake (Space or another key)
	if Input.is_action_pressed("ui_select"):  # You can change this to a custom action
		var brake_force = brake_strength * delta
		if abs(current_speed) > brake_force:
			current_speed -= sign(current_speed) * brake_force
		else:
			current_speed = 0.0
	
	# Steering (only when moving)
	if abs(current_speed) > 10:
		var input_horizontal = Input.get_axis("ui_left", "ui_right")
		if input_horizontal != 0:
			# Turn rate depends on speed (slower when going fast)
			var turn_modifier = 1.0 - (abs(current_speed) / max_speed) * 0.5
			var turn_amount = input_horizontal * turn_speed * turn_modifier * delta * sign(current_speed)
			
			# Update both visual and movement angles
			visual_rotation += turn_amount
			movement_angle += turn_amount

func apply_movement(delta):
	# Calculate movement direction
	var direction = Vector2.RIGHT.rotated(movement_angle)
	
	# Apply velocity
	velocity = direction * current_speed
	
	# Smooth the movement angle toward visual rotation (helps with drifting feel)
	if abs(current_speed) > 10:  # Only apply smoothing when moving
		movement_angle = lerp_angle(movement_angle, visual_rotation, 0.1)

func world_to_isometric(world_pos: Vector2) -> Vector2:
	# Convert world coordinates to isometric coordinates
	var iso_x = world_pos.x / tile_size.x + world_pos.y / tile_size.y
	var iso_y = world_pos.y / tile_size.y - world_pos.x / tile_size.x
	return Vector2(iso_x, iso_y)

func isometric_to_world(iso_pos: Vector2) -> Vector2:
	# Convert isometric coordinates to world coordinates
	var world_x = (iso_pos.x - iso_pos.y) * tile_size.x / 2
	var world_y = (iso_pos.x + iso_pos.y) * tile_size.y / 2
	return Vector2(world_x, world_y)

# Get current tile position
func get_tile_position() -> Vector2i:
	var iso_pos = world_to_isometric(global_position)
	return Vector2i(round(iso_pos.x), round(iso_pos.y))

# Optional: Snap to nearest road angle (call this when you want to align with roads)
func snap_to_road_angle():
	# 8 possible directions in isometric view (45-degree increments)
	var angles = []
	for i in 8:
		angles.append(deg_to_rad(i * 45 - isometric_angle))
	
	# Find closest angle
	var closest_angle = angles[0]
	var min_diff = abs(angle_difference(visual_rotation, angles[0]))
	
	for angle in angles:
		var diff = abs(angle_difference(visual_rotation, angle))
		if diff < min_diff:
			min_diff = diff
			closest_angle = angle
	
	visual_rotation = closest_angle
	movement_angle = closest_angle

# Debug drawing
func _draw():
	if not show_debug_vectors:
		return
	
	# Draw velocity vector (green) - where we're actually moving
	if velocity.length() > 0:
		# Velocity is in world space, need to convert to local space
		var local_velocity = velocity.rotated(-rotation) * vector_scale
		draw_line(Vector2.ZERO, local_velocity, velocity_color, 3.0)
		draw_circle(local_velocity, 5, velocity_color)
	
	# Draw direction vector (blue) - where we're facing
	# This is already correct as it's based on visual rotation
	var facing_direction = Vector2.RIGHT * 100 * vector_scale
	draw_line(Vector2.ZERO, facing_direction, direction_color, 2.0)
	draw_circle(facing_direction, 4, direction_color)
	
	# Draw movement direction (yellow) - actual movement angle
	if abs(movement_angle - visual_rotation) > 0.01:
		var move_dir_world = Vector2.RIGHT.rotated(movement_angle)
		var move_dir_local = move_dir_world.rotated(-rotation) * 80 * vector_scale
		draw_line(Vector2.ZERO, move_dir_local, Color.YELLOW, 1.0)
		draw_circle(move_dir_local, 3, Color.YELLOW)
	
	# Draw current info
	var font = ThemeDB.fallback_font
	var y_offset = 0
	
	draw_string(font, Vector2(20, y_offset), "Speed: %d" % int(velocity.length()), 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	
	if show_tile_position:
		y_offset -= 20
		var tile_pos = get_tile_position()
		draw_string(font, Vector2(20, y_offset), "Tile: %s" % str(tile_pos), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

func angle_difference(from: float, to: float) -> float:
	var diff = to - from
	while diff > PI:
		diff -= TAU
	while diff < -PI:
		diff += TAU
	return diff
