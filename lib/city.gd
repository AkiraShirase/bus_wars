extends Node2D

# The speed at which the camera moves on the x and y axes.
@export var move_speed = 400.0
@export var vehicle: GameVehicle
@export var debug: BusDebugVectors
@export var level: BusLevel

# A reference to the Camera2D child node.
@onready var camera_2d = $Camera2D

# Driver and vehicle properties
var driver: Driver

# Controllers
var _player_controller: PlayerController
var _vehicle_controller: VehicleController
var _level_controller: LevelController

func _ready():
	# Initialize components
	driver = Driver.new()
	_player_controller = PlayerController.new()
	_vehicle_controller = VehicleController.new(
		VehicleAccelerationDefaultController.new(),
		VehicleSteeringDefaultController.new(),
	)
	if vehicle:
		_vehicle_controller.initialize_vehicle(vehicle)

func _process(delta):
	# Update driver input
	_player_controller.update(driver)
	
	# Update vehicle steering
	if vehicle:
		_vehicle_controller.update(vehicle, driver)

	if level:
		_level_controller.init(level)
		
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
