extends Node
class_name VehicleController

var _acceleration_controller: VehicleAccelerationController
var _steering_controller: VehicleSteeringController

func _init(accel_controller: VehicleAccelerationController, steer_controller: VehicleSteeringController):
	_acceleration_controller = accel_controller
	_steering_controller = steer_controller

func update(vehicle: GameVehicle, driver: Driver) -> void:
	_acceleration_controller.accelerate(vehicle, driver)
	_steering_controller.steer(driver, vehicle)
	_apply_movement(vehicle)

func initialize_vehicle(vehicle: GameVehicle) -> void:
	_steering_controller.init(vehicle)	

func _apply_movement(vehicle: GameVehicle) -> void:
	var collision = vehicle.move_and_collide(vehicle.velocity * vehicle.get_physics_process_delta_time())
	if collision:
		_acceleration_controller.apply_collision_impact(vehicle, collision)