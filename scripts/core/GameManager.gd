extends Node

signal game_state_changed(new_state)
signal passenger_count_changed(count)

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
var total_passengers_transported: int = 0
var active_buses: Array[Node] = []
var bus_stops: Array[Node] = []

func _ready():
	set_game_state(GameState.PLAYING)

func set_game_state(new_state: GameState):
	current_state = new_state
	game_state_changed.emit(new_state)
	
	match new_state:
		GameState.PLAYING:
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.GAME_OVER:
			get_tree().paused = true

func register_bus(bus: Node):
	if bus not in active_buses:
		active_buses.append(bus)

func unregister_bus(bus: Node):
	if bus in active_buses:
		active_buses.erase(bus)

func register_bus_stop(stop: Node):
	if stop not in bus_stops:
		bus_stops.append(stop)

func passenger_transported():
	total_passengers_transported += 1
	passenger_count_changed.emit(total_passengers_transported)

func get_passenger_count() -> int:
	return total_passengers_transported

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.PLAYING:
			set_game_state(GameState.PAUSED)
		elif current_state == GameState.PAUSED:
			set_game_state(GameState.PLAYING)
