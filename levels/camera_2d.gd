extends Camera2D

# Reference to the target (bus) to follow
@export var target_path: NodePath
@export var follow_speed: float = 5.0
@export var offset_distance: float = 0.0  # How far ahead to look
@export var zoom_level: Vector2 = Vector2(0.5, 0.5)

# Shake parameters
@export var shake_decay: float = 0.8
@export var max_shake_offset: float = 10.0

var target: Node2D
var shake_strength: float = 0.0

func _ready():
	if target_path:
		target = get_node(target_path)
	
	# Set initial zoom
	zoom = zoom_level
	
	# Enable camera
	enabled = true
	
	# Optional: Set limits for the camera
	# limit_left = 0
	# limit_top = 0
	# limit_right = 1920
	# limit_bottom = 1080

func _physics_process(delta):
	if not target:
		return
	
	# Get target position with optional look-ahead
	var target_pos = target.global_position
	
	# Add look-ahead based on velocity if target is CharacterBody2D
	if offset_distance > 0:
		var velocity_offset = target.velocity.normalized() * offset_distance
		target_pos += velocity_offset
	
	# Smooth follow
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# Apply camera shake if active
	if shake_strength > 0:
		shake_strength = max(shake_strength - shake_decay * delta, 0)
		var shake_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		offset = shake_offset

# Call this to shake the camera (e.g., on collision)
func shake(strength: float):
	shake_strength = min(strength, max_shake_offset)

# Zoom controls
func zoom_in():
	zoom = zoom * 1.1
	zoom = zoom.clamp(Vector2(0.1, 0.1), Vector2(2.0, 2.0))

func zoom_out():
	zoom = zoom * 0.9
	zoom = zoom.clamp(Vector2(0.1, 0.1), Vector2(2.0, 2.0))

# Set zoom directly
func set_zoom_level(new_zoom: float):
	zoom = Vector2(new_zoom, new_zoom)
	zoom = zoom.clamp(Vector2(0.1, 0.1), Vector2(2.0, 2.0))
