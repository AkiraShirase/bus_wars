extends Node
class_name PlayerController

func update(driver: Driver) -> void:
	_update_acceleration(driver)
	_update_steering(driver)
	_update_stopping(driver)

func _update_acceleration(driver: Driver) -> void:
	driver.accelerating = 100 if Input.is_action_pressed("accelerate") else 0

func _update_steering(driver: Driver) -> void:
	if Input.is_action_pressed("steer_left"):
		driver.steering = 0
		return
	
	if Input.is_action_pressed("steer_right"):
		driver.steering = 100
		return
	
	driver.steering = 50

func _update_stopping(driver: Driver) -> void:
	driver.stopping = 100 if Input.is_action_pressed("brake") else 0
