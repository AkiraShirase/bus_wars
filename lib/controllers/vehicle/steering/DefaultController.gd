extends VehicleSteeringController
class_name VehicleSteeringDefaultController

const _turn_amount: float = 2.0

func steer(driver: Driver, vehicle: GameVehicle) -> void:
	if driver.steering == 50:
		return

	var delta = _turn_amount if driver.steering > 50 else -_turn_amount
	vehicle.direct(vehicle.direction.rotated(delta * vehicle.get_process_delta_time()))

func init(vehicle: GameVehicle) -> void:
	var direction_angles = {
		GameVehicle.StartDirection.EAST: 0 - vehicle.isometric_angle,
		GameVehicle.StartDirection.SOUTHEAST: 45 - vehicle.isometric_angle,
		GameVehicle.StartDirection.SOUTH: 90 - vehicle.isometric_angle,
		GameVehicle.StartDirection.SOUTHWEST: 135 - vehicle.isometric_angle,
		GameVehicle.StartDirection.WEST: 180 - vehicle.isometric_angle,
		GameVehicle.StartDirection.NORTHWEST: 225 - vehicle.isometric_angle,
		GameVehicle.StartDirection.NORTH: 270 - vehicle.isometric_angle,
		GameVehicle.StartDirection.NORTHEAST: 315 - vehicle.isometric_angle
	}
	
	var direction = Vector2.RIGHT.rotated(deg_to_rad(direction_angles[vehicle.start_direction]))
	vehicle.direct(direction)
