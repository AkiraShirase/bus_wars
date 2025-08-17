# TireMaterial.gd
extends Resource
class_name TireMaterial

enum TireType {
	STANDARD,
	PERFORMANCE,
	ALL_TERRAIN,
	WINTER,
	RACING,
	HOVER,
	QUANTUM
}

@export var tire_type: TireType = TireType.STANDARD
@export var wear_level: float = 100.0  # 100 = new, 0 = worn out
@export var pressure: float = 100.0  # 100 = optimal
@export var temperature: float = 20.0  # Celsius

func get_tire_properties() -> Dictionary:
	match tire_type:
		TireType.STANDARD:
			return {
				"grip": 0.7,
				"durability": 0.8,
				"speed_rating": 0.6,
				"noise": 0.5,
				"cost": 0.5
			}
		TireType.PERFORMANCE:
			return {
				"grip": 0.9,
				"durability": 0.6,
				"speed_rating": 0.9,
				"noise": 0.7,
				"cost": 0.8
			}
		TireType.ALL_TERRAIN:
			return {
				"grip": 0.8,
				"durability": 0.9,
				"speed_rating": 0.5,
				"noise": 0.8,
				"cost": 0.7
			}
		TireType.WINTER:
			return {
				"grip": 0.6,  # Base grip, increases in cold
				"durability": 0.7,
				"speed_rating": 0.4,
				"noise": 0.6,
				"cost": 0.6
			}
		TireType.RACING:
			return {
				"grip": 1.0,
				"durability": 0.3,
				"speed_rating": 1.0,
				"noise": 0.9,
				"cost": 1.0
			}
		TireType.HOVER:
			return {
				"grip": 0.5,  # Magnetic/energy grip
				"durability": 0.95,
				"speed_rating": 0.8,
				"noise": 0.1,
				"cost": 2.0
			}
		TireType.QUANTUM:
			return {
				"grip": 0.85,
				"durability": 1.0,
				"speed_rating": 0.95,
				"noise": 0.0,
				"cost": 5.0
			}
		_:
			return {
				"grip": 0.7,
				"durability": 0.7,
				"speed_rating": 0.7,
				"noise": 0.7,
				"cost": 1.0
			}

func get_acceleration_modifier() -> float:
	var props = get_tire_properties()
	var base_grip = props["grip"]
	
	# Wear affects grip
	var wear_modifier = (wear_level / 100.0) * 0.5 + 0.5  # 50% to 100%
	
	# Pressure affects performance
	var pressure_modifier = 1.0 - abs(pressure - 100.0) / 200.0
	
	# Temperature affects grip (optimal around 60-80C for performance)
	var temp_modifier = 1.0
	if tire_type == TireType.WINTER:
		# Winter tires work better in cold
		temp_modifier = 1.2 if temperature < 10.0 else 0.8
	else:
		# Normal tires work worse in extreme temps
		if temperature < 0.0:
			temp_modifier = 0.6
		elif temperature > 100.0:
			temp_modifier = 0.7
	
	return base_grip * wear_modifier * pressure_modifier * temp_modifier

func get_braking_modifier() -> float:
	# Similar to acceleration but more sensitive to wear
	var accel_mod = get_acceleration_modifier()
	var wear_penalty = (100.0 - wear_level) / 100.0 * 0.3
	return accel_mod - wear_penalty

func get_steering_stability(speed: float) -> float:
	var props = get_tire_properties()
	var base_stability = props["grip"] * 0.7 + props["speed_rating"] * 0.3
	
	# High speed reduces stability
	var speed_factor = 1.0 - (speed / 500.0)  # Assuming max speed ~500
	speed_factor = clamp(speed_factor, 0.3, 1.0)
	
	# Wear affects stability
	var wear_modifier = (wear_level / 100.0) * 0.6 + 0.4
	
	return base_stability * speed_factor * wear_modifier

func update_wear(delta: float, speed: float, acceleration: float):
	var props = get_tire_properties()
	var wear_rate = (1.0 - props["durability"]) * 0.01
	
	# Wear increases with speed and acceleration
	var usage_factor = (abs(speed) / 300.0 + abs(acceleration) / 500.0) / 2.0
	
	wear_level -= wear_rate * usage_factor * delta
	wear_level = clamp(wear_level, 0.0, 100.0)

func update_temperature(delta: float, speed: float, ambient_temp: float = 20.0):
	# Temperature increases with speed/friction
	var heat_generation = (speed / 300.0) * 50.0  # Up to 50C from friction
	
	# Cool down towards ambient
	var target_temp = ambient_temp + heat_generation
	temperature = lerp(temperature, target_temp, delta * 0.5)
	
	# Update pressure based on temperature (ideal gas law)
	pressure = 100.0 + (temperature - 20.0) * 0.3
	pressure = clamp(pressure, 80.0, 120.0)
