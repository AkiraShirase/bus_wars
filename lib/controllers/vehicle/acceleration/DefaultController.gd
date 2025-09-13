extends Node
class_name AccelerationDefaultController

const acceleration: float = 100.0
const deceleration: float = 100.0

func accelerate(vehicle: Vehicle, driver: Driver) -> void:
	if driver.accelerating > 0:
		vehicle.current_speed += acceleration * get_process_delta_time()
	elif driver.stopping > 0:
		vehicle.current_speed -= deceleration * get_process_delta_time()