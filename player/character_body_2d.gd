extends CharacterBody2D

# Movement variables
@export var max_speed: float = 300.0
@export var acceleration: float = 500.0
@export var friction: float = 400.0
@export var turn_speed: float = 2.0  # Radians per second

# Current movement state
var current_speed: float = 0.0
var target_angle: float = 0.0

func _ready():
	# Initialize rotation to face right (typical for isometric)
	rotation = 0
	# Create camera if needed
	var camera = Camera2D.new()
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.zoom = Vector2(0.5, 0.5)
	add_child(camera)

func _physics_process(delta):
	handle_input(delta)
	apply_movement(delta)
	move_and_slide()

func handle_input(delta):
	# Forward/Backward movement
	var input_vertical = Input.get_axis("ui_down", "ui_up")  # up = forward, down = reverse
	
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
	
	# Steering (only when moving)
	if abs(current_speed) > 10:
		var input_horizontal = Input.get_axis("ui_left", "ui_right")
		if input_horizontal != 0:
			# Turn rate depends on speed (slower when going fast)
			var turn_modifier = 1.0 - (abs(current_speed) / max_speed) * 0.5
			rotation += input_horizontal * turn_speed * turn_modifier * delta * sign(current_speed)

func apply_movement(delta):
	# Convert rotation to direction vector
	var direction = Vector2.RIGHT.rotated(rotation)
	
	# Apply velocity based on current speed and direction
	velocity = direction * current_speed
	
	# Optional: Add some drift/slide effect for more realistic feel
	# velocity = velocity.lerp(direction * current_speed, 0.1)

# Optional: Get world position for isometric conversion
func get_iso_position() -> Vector2:
	# Convert world position to isometric coordinates
	var world_pos = global_position
	var iso_x = (world_pos.x - world_pos.y) * 0.5
	var iso_y = (world_pos.x + world_pos.y) * 0.25
	return Vector2(iso_x, iso_y)

# Optional: Set position from isometric coordinates
func set_iso_position(iso_pos: Vector2):
	# Convert isometric to world coordinates
	var world_x = iso_pos.x + iso_pos.y * 2
	var world_y = iso_pos.y * 2 - iso_pos.x
	global_position = Vector2(world_x, world_y)
