extends Node
class_name AccelerationDefaultController

const acceleration: float = 100.0
const deceleration: float = 100.0

func accelerate(vehicle: GameVehicle, driver: Driver) -> void:
	if driver.accelerating > 0:
		vehicle.current_speed += acceleration * vehicle.get_process_delta_time()
		if vehicle.current_speed > vehicle.effective_max_speed:
			vehicle.current_speed = vehicle.effective_max_speed
	if driver.stopping > 0:
		vehicle.current_speed -= deceleration * vehicle.get_process_delta_time()
		if vehicle.current_speed < 0 && abs(vehicle.current_speed) > vehicle.effective_max_speed:
			vehicle.current_speed = -vehicle.effective_max_speed
	
	vehicle.direction = Vector2.RIGHT.rotated(vehicle.movement_angle)
	vehicle.velocity = vehicle.direction * vehicle.current_speed
