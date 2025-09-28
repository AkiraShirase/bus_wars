extends VehicleAccelerationController
class_name VehicleAccelerationDefaultController

const acceleration: float = 100.0
const deceleration: float = -100.0
const stop: float = 10

func accelerate(vehicle: GameVehicle, driver: Driver) -> void:
	var amount = stop if vehicle.current_speed < 0 else -stop
	if driver.accelerating > 0:
		amount = acceleration
	if driver.stopping > 0:
		amount = deceleration
	
	var new_speed = vehicle.current_speed + amount	
	if new_speed > vehicle.effective_max_speed:
		amount = vehicle.effective_max_speed - vehicle.current_speed
	elif new_speed < 0 and vehicle.stopping:
		return
	elif new_speed < -vehicle.effective_max_speed:
		amount = vehicle.effective_max_speed + vehicle.current_speed
	
	vehicle.change_speed(amount)
