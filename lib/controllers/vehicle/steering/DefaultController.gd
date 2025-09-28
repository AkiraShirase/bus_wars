extends VehicleSteeringController
class_name VehicleSteeringDefaultController

const _turn_amount: float = 2.0

func steer(driver: Driver, vehicle: GameVehicle) -> void:
	if driver.steering == 50:
		return

	var delta = _turn_amount if driver.steering > 50 else -_turn_amount
	vehicle.direct(delta)
	vehicle.steer(vehicle.visual_rotation + (delta * vehicle.get_process_delta_time()))
