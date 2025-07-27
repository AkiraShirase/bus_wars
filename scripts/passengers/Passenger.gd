extends Node3D

class_name Passenger

signal arrived_at_destination

@export var passenger_name: String = ""
@export var danger_level: float = 0.0
@export var faith_level: float = 1.0
@export var destination_stop: Node = null

var current_bus: Bus = null
var is_waiting: bool = true
var is_in_transit: bool = false
var pickup_time: float = 0.0

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready():
	create_passenger_mesh()
	if passenger_name.is_empty():
		passenger_name = generate_random_name()

func create_passenger_mesh():
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.3
	capsule_mesh.height = 1.5
	mesh_instance.mesh = capsule_mesh

func generate_random_name() -> String:
	var first_names = ["Alex", "Sam", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Avery"]
	var last_names = ["Smith", "Johnson", "Brown", "Davis", "Wilson", "Miller", "Moore", "Taylor"]
	
	return first_names[randi() % first_names.size()] + " " + last_names[randi() % last_names.size()]

func board_bus(bus: Bus) -> bool:
	if is_waiting and bus.add_passenger(self):
		current_bus = bus
		is_waiting = false
		is_in_transit = true
		visible = false
		pickup_time = Time.get_time_dict_from_system()["hour"] * 60 + Time.get_time_dict_from_system()["minute"]
		return true
	return false

func exit_bus():
	if current_bus and current_bus.remove_passenger(self):
		current_bus = null
		is_in_transit = false
		visible = true
		
		if destination_stop:
			arrived_at_destination.emit()
			if GameManager:
				GameManager.passenger_transported()

func set_destination(stop: Node):
	destination_stop = stop

func get_riot_probability() -> float:
	return danger_level * 0.1

func get_bus_choice_probability() -> float:
	return faith_level * 0.8 + randf() * 0.2