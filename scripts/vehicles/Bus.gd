extends RigidBody3D

class_name Bus

signal passenger_picked_up(passenger)
signal passenger_dropped_off(passenger)

@export var engine_power: float = 1500.0
@export var brake_power: float = 3000.0
@export var steering_power: float = 30.0
@export var max_speed: float = 20.0
@export var weight: float = 1000.0
@export var max_passenger_capacity: int = 40

var current_passengers: Array[Node] = []
var acceleration_input: float = 0.0
var steering_input: float = 0.0
var current_route: Array[Vector3] = []
var current_route_index: int = 0

# Button input states
var button_accelerate_pressed: bool = false
var button_brake_pressed: bool = false
var button_steer_left_pressed: bool = false
var button_steer_right_pressed: bool = false

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready():
	mass = weight
	# Set RigidBody3D properties for proper physics
	gravity_scale = 1.0
	# Set collision layers - bus should be on layer 2 and collide with environment (layer 1)
	collision_layer = 2  # Buses layer
	collision_mask = 1   # Collide with Environment layer
	create_bus_mesh()
	# Register with GameManager after the scene tree is ready
	call_deferred("_register_with_game_manager")

func _register_with_game_manager():
	GameManager.register_bus(self)

func _physics_process(delta):
	handle_input()
	apply_engine_force(delta)
	apply_steering(delta)
	limit_speed()

func handle_input():
	acceleration_input = 0.0
	steering_input = 0.0
	
	# Handle keyboard input
	var keyboard_accelerate = Input.is_action_pressed("accelerate")
	var keyboard_brake = Input.is_action_pressed("brake")
	var keyboard_steer_left = Input.is_action_pressed("steer_left")
	var keyboard_steer_right = Input.is_action_pressed("steer_right")
	
	# Combine keyboard and button inputs
	if keyboard_accelerate or button_accelerate_pressed:
		acceleration_input = 1.0
	elif keyboard_brake or button_brake_pressed:
		acceleration_input = -1.0
	
	if keyboard_steer_left or button_steer_left_pressed:
		steering_input = -1.0
	elif keyboard_steer_right or button_steer_right_pressed:
		steering_input = 1.0

func apply_engine_force(delta):
	var forward = -transform.basis.z
	var force = forward * acceleration_input * engine_power
	
	if acceleration_input < 0:
		force *= brake_power / engine_power
	
	apply_central_force(force)

func apply_steering(delta):
	if abs(linear_velocity.length()) > 0.1:
		var steering_force = steering_input * steering_power
		apply_torque(Vector3.UP * steering_force)

func limit_speed():
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func add_passenger(passenger: Node) -> bool:
	if current_passengers.size() < max_passenger_capacity:
		current_passengers.append(passenger)
		passenger_picked_up.emit(passenger)
		return true
	return false

func remove_passenger(passenger: Node) -> bool:
	if passenger in current_passengers:
		current_passengers.erase(passenger)
		passenger_dropped_off.emit(passenger)
		return true
	return false

func get_passenger_count() -> int:
	return current_passengers.size()

func set_route(route: Array[Vector3]):
	current_route = route
	current_route_index = 0

func create_bus_mesh():
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(2, 1, 4)
	mesh_instance.mesh = box_mesh
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(2, 1, 4)
	collision_shape.shape = box_shape

func _on_tree_exiting():
	if GameManager:
		GameManager.unregister_bus(self)

# Button input methods
func on_accelerate_pressed():
	button_accelerate_pressed = true

func on_accelerate_released():
	button_accelerate_pressed = false

func on_brake_pressed():
	button_brake_pressed = true

func on_brake_released():
	button_brake_pressed = false

func on_steer_left_pressed():
	button_steer_left_pressed = true

func on_steer_left_released():
	button_steer_left_pressed = false

func on_steer_right_pressed():
	button_steer_right_pressed = true

func on_steer_right_released():
	button_steer_right_pressed = false