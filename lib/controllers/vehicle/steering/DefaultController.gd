extends Node
class_name DefaultController

const _turn_amount: float = 2.0

func steer(driver: Driver, vehicle: Vehicle) -> void:
	if driver.steering > 50:
		_turn_right(vehicle)
	elif driver.steering < 50:
		_turn_left(vehicle)

func _turn_right(vehicle: Vehicle) -> void:
	vehicle.visual_rotation += _turn_amount * get_process_delta_time()
	vehicle.movement_angle += _turn_amount * get_process_delta_time()

func _turn_left(vehicle: Vehicle) -> void:
	vehicle.visual_rotation -= _turn_amount * get_process_delta_time()
	vehicle.movement_angle -= _turn_amount * get_process_delta_time()