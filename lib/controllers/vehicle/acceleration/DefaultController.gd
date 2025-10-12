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

func apply_collision_impact(vehicle: GameVehicle, _collision: KinematicCollision2D) -> void:
	# Calculate impact speed based on current velocity
	# The faster the speed, the more it bounces back in the opposite direction
	var velocity_magnitude = vehicle.velocity.length()

	# The impact speed is proportional to the velocity
	# Faster speeds result in stronger bounce back in opposite direction
	var impact_factor = velocity_magnitude / vehicle.effective_max_speed if vehicle.effective_max_speed > 0 else 1.0

	# Reverse the speed direction: if moving forward (positive), bounce back (negative)
	# If moving backward (negative), bounce forward (positive)
	var collision_speed = -vehicle.current_speed * impact_factor * 0.75

	vehicle.current_speed = collision_speed
