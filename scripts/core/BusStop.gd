extends Node3D

class_name BusStop

signal passenger_spawned(passenger)
signal bus_arrived(bus)
signal bus_departed(bus)

@export var stop_name: String = "Bus Stop"
@export var max_passengers: int = 20
@export var danger_level: float = 0.0
@export var faith_level: float = 1.0
@export var spawn_rate: float = 0.1

var waiting_passengers: Array[Passenger] = []
var passenger_scene = preload("res://scenes/characters/Passenger.tscn")

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var area_3d: Area3D = $Area3D
@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	GameManager.register_bus_stop(self)
	create_bus_stop_mesh()
	setup_detection_area()
	setup_passenger_spawning()

func create_bus_stop_mesh():
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.5
	cylinder_mesh.bottom_radius = 0.5
	cylinder_mesh.height = 3.0
	mesh_instance.mesh = cylinder_mesh

func setup_detection_area():
	area_3d.body_entered.connect(_on_bus_entered)
	area_3d.body_exited.connect(_on_bus_exited)
	
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 3.0
	collision_shape.shape = sphere_shape
	area_3d.add_child(collision_shape)

func setup_passenger_spawning():
	spawn_timer.wait_time = 1.0 / spawn_rate
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if waiting_passengers.size() < max_passengers:
		spawn_passenger()

func spawn_passenger():
	var passenger = passenger_scene.instantiate() as Passenger
	passenger.global_position = global_position + Vector3(
		randf_range(-2, 2), 0, randf_range(-2, 2)
	)
	
	passenger.danger_level = danger_level + randf_range(-0.1, 0.1)
	passenger.faith_level = faith_level + randf_range(-0.1, 0.1)
	
	get_parent().add_child(passenger)
	waiting_passengers.append(passenger)
	passenger_spawned.emit(passenger)

func _on_bus_entered(body):
	if body is Bus:
		bus_arrived.emit(body)
		handle_passenger_boarding(body)

func _on_bus_exited(body):
	if body is Bus:
		bus_departed.emit(body)

func handle_passenger_boarding(bus: Bus):
	var passengers_to_board = []
	
	for passenger in waiting_passengers:
		if passenger.get_bus_choice_probability() > 0.5:
			if passenger.board_bus(bus):
				passengers_to_board.append(passenger)
	
	for passenger in passengers_to_board:
		waiting_passengers.erase(passenger)

func get_waiting_passenger_count() -> int:
	return waiting_passengers.size()