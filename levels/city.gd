extends Node2D

# The speed at which the camera moves on the x and y axes.
@export var move_speed = 400.0

# A reference to the Camera2D child node.
@onready var camera_2d = $Camera2D

func _process(delta):
	# Start with a zero vector for velocity.
	#var velocity = Vector2.ZERO
	# Handle horizontal movement (x-axis).
	#if Input.is_action_pressed("steer_right"):
	#	velocity.x += 1

	#if Input.is_action_pressed("steer_left"):
	#	velocity.x -= 1

	# Handle vertical movement (y-axis).
	#if Input.is_action_pressed("brake"):
	#	velocity.y += 1 # Moves down
	#if Input.is_action_pressed("accelerate"):
	#	velocity.y -= 1 # Moves up

	# Normalize the velocity to prevent faster diagonal movement
	# and then apply speed and delta time.
	#velocity = velocity.normalized() * move_speed * delta

	# Update the camera's position.
	#camera_2d.position += velocity
