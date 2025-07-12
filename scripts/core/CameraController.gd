extends Node3D

@onready var camera: Camera3D = $Camera3D

var target_position: Vector3
var camera_speed: float = 5.0
var zoom_speed: float = 2.0
var min_zoom: float = 5.0
var max_zoom: float = 50.0

var is_panning: bool = false
var last_mouse_position: Vector2

func _ready():
	target_position = global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
			last_mouse_position = event.position
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(zoom_speed)
	
	elif event is InputEventMouseMotion and is_panning:
		var delta_mouse = event.position - last_mouse_position
		pan_camera(delta_mouse)
		last_mouse_position = event.position

func _process(delta):
	global_position = global_position.lerp(target_position, camera_speed * delta)

func pan_camera(mouse_delta: Vector2):
	var pan_factor = camera.size * 0.001
	var right = transform.basis.x
	var forward = -transform.basis.z
	
	target_position -= right * mouse_delta.x * pan_factor
	target_position -= forward * mouse_delta.y * pan_factor

func zoom_camera(zoom_delta: float):
	var new_size = camera.size + zoom_delta
	camera.size = clamp(new_size, min_zoom, max_zoom)

func follow_target(target: Node3D):
	if target:
		target_position = target.global_position + Vector3(0, 10, 10)