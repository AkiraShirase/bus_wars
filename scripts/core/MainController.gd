extends Node3D

class_name MainController

@onready var controls_ui = $UI/ControlsUI
var player_bus: Bus = null

func _ready():
	# Wait for scene to be ready before connecting
	call_deferred("_setup_connections")

func _setup_connections():
	# Find the player bus in the scene
	player_bus = find_player_bus()
	
	if player_bus and controls_ui:
		# Connect UI signals to bus methods
		controls_ui.accelerate_pressed.connect(player_bus.on_accelerate_pressed)
		controls_ui.accelerate_released.connect(player_bus.on_accelerate_released)
		controls_ui.brake_pressed.connect(player_bus.on_brake_pressed)
		controls_ui.brake_released.connect(player_bus.on_brake_released)
		controls_ui.steer_left_pressed.connect(player_bus.on_steer_left_pressed)
		controls_ui.steer_left_released.connect(player_bus.on_steer_left_released)
		controls_ui.steer_right_pressed.connect(player_bus.on_steer_right_pressed)
		controls_ui.steer_right_released.connect(player_bus.on_steer_right_released)
		
		print("Controls connected to player bus successfully")
	else:
		print("Failed to connect controls - missing player bus or controls UI")

func find_player_bus() -> Bus:
	# Search for the player bus in the scene tree
	var buses = get_tree().get_nodes_in_group("player_bus")
	if buses.size() > 0:
		return buses[0] as Bus
	
	# Fallback: search by name
	var player_bus_node = get_node_or_null("Level/TestLevel/Vehicles/PlayerBus")
	if player_bus_node and player_bus_node is Bus:
		return player_bus_node as Bus
	
	# Last resort: find any Bus node
	return find_child("Bus", true, false) as Bus