extends Control

class_name ControlsUI

signal accelerate_pressed
signal accelerate_released
signal brake_pressed
signal brake_released
signal steer_left_pressed
signal steer_left_released
signal steer_right_pressed
signal steer_right_released

@onready var accelerate_button: Button = $VBoxContainer/AccelerateBrakeContainer/AccelerateButton
@onready var brake_button: Button = $VBoxContainer/AccelerateBrakeContainer/BrakeButton
@onready var steer_left_button: Button = $VBoxContainer/SteeringContainer/SteerLeftButton
@onready var steer_right_button: Button = $VBoxContainer/SteeringContainer/SteerRightButton

func _ready():
	setup_button_connections()

func setup_button_connections():
	# Accelerate button
	accelerate_button.button_down.connect(_on_accelerate_pressed)
	accelerate_button.button_up.connect(_on_accelerate_released)
	
	# Brake button
	brake_button.button_down.connect(_on_brake_pressed)
	brake_button.button_up.connect(_on_brake_released)
	
	# Steering buttons
	steer_left_button.button_down.connect(_on_steer_left_pressed)
	steer_left_button.button_up.connect(_on_steer_left_released)
	
	steer_right_button.button_down.connect(_on_steer_right_pressed)
	steer_right_button.button_up.connect(_on_steer_right_released)

func _on_accelerate_pressed():
	accelerate_pressed.emit()

func _on_accelerate_released():
	accelerate_released.emit()

func _on_brake_pressed():
	brake_pressed.emit()

func _on_brake_released():
	brake_released.emit()

func _on_steer_left_pressed():
	steer_left_pressed.emit()

func _on_steer_left_released():
	steer_left_released.emit()

func _on_steer_right_pressed():
	steer_right_pressed.emit()

func _on_steer_right_released():
	steer_right_released.emit()