# EnginePower.gd
extends Resource
class_name EnginePower

@export var base_power: float = 200.0  # kW
@export var torque: float = 500.0  # Nm
@export var efficiency: float = 0.85  # 0.0 to 1.0
@export var rpm_min: float = 800.0
@export var rpm_max: float = 4000.0
@export var rpm_optimal: float = 2500.0

# Current state
var current_rpm: float = 800.0
var temperature: float = 20.0
var fuel_consumption_rate: float = 0.0

# Power source specific limits
var power_limits = {
	"steam": {"min": 50.0, "max": 300.0, "efficiency": 0.4},
	"gas": {"min": 100.0, "max": 500.0, "efficiency": 0.35},
	"hydrogen": {"min": 150.0, "max": 600.0, "efficiency": 0.6},
	"battery": {"min": 100.0, "max": 800.0, "efficiency": 0.9},
	"alien": {"min": 300.0, "max": 2000.0, "efficiency": 0.95},
	"psychic": {"min": 50.0, "max": 1000.0, "efficiency": 0.8},
	"chaos": {"min": 0.0, "max": 3000.0, "efficiency": 0.3}
}

func get_max_power(power_source: String) -> float:
	if power_source in power_limits:
		return clamp(base_power, power_limits[power_source]["min"], power_limits[power_source]["max"])
	return base_power

func get_current_power(power_source: String, throttle: float) -> float:
	var max_power = get_max_power(power_source)
	
	# RPM affects power output
	var rpm_factor = 1.0
	if current_rpm < rpm_optimal:
		rpm_factor = (current_rpm - rpm_min) / (rpm_optimal - rpm_min)
	else:
		rpm_factor = 1.0 - (current_rpm - rpm_optimal) / (rpm_max - rpm_optimal) * 0.3
	rpm_factor = clamp(rpm_factor, 0.1, 1.0)
	
	# Temperature affects efficiency
	var temp_factor = 1.0
	if temperature < 60.0:
		temp_factor = 0.7 + (temperature / 60.0) * 0.3  # Cold engine
	elif temperature > 100.0:
		temp_factor = 1.0 - (temperature - 100.0) / 100.0 * 0.5  # Overheating
	
	# Power source efficiency
	var source_efficiency = efficiency
	if power_source in power_limits:
		source_efficiency *= power_limits[power_source]["efficiency"]
	
	# Special power source behaviors
	match power_source:
		"psychic":
			# Power fluctuates based on "mental energy"
			var fluctuation = sin(Time.get_ticks_msec() / 1000.0) * 0.2 + 1.0
			rpm_factor *= fluctuation
		"chaos":
			# Completely random power spikes
			rpm_factor *= randf_range(0.5, 2.0)
	
	return max_power * throttle * rpm_factor * temp_factor * source_efficiency

func get_torque_at_rpm() -> float:
	# Torque curve - typically higher at lower RPM
	var rpm_ratio = (current_rpm - rpm_min) / (rpm_max - rpm_min)
	var torque_multiplier = 1.0 - rpm_ratio * 0.4  # Loses 40% torque at max RPM
	return torque * torque_multiplier

func update_rpm(speed: float, gear_ratio: float = 3.5):
	# Simple RPM calculation based on speed
	var wheel_rpm = speed * 60.0 / (2.0 * PI * 0.35)  # Assuming 0.35m wheel radius
	current_rpm = wheel_rpm * gear_ratio
	current_rpm = clamp(current_rpm, rpm_min, rpm_max)

func update_temperature(delta: float, throttle: float, ambient_temp: float = 20.0):
	# Heat generation based on power output
	var heat_rate = throttle * 50.0  # Max 50C/s at full throttle
	
	# Cooling rate
	var cooling_rate = (temperature - ambient_temp) * 0.5
	
	temperature += (heat_rate - cooling_rate) * delta
	temperature = clamp(temperature, ambient_temp, 150.0)

func calculate_fuel_consumption(power_source: String, throttle: float) -> float:
	var base_consumption = throttle * 10.0  # L/hour at full throttle
	
	match power_source:
		"steam":
			return base_consumption * 2.0  # Uses water/coal
		"gas":
			return base_consumption
		"hydrogen":
			return base_consumption * 0.5
		"battery":
			return base_consumption * 0.3  # kWh instead of liters
		"alien":
			return base_consumption * 0.1  # Very efficient
		"psychic":
			return 0.0  # Uses mental energy
		"chaos":
			return randf_range(0.0, base_consumption * 3.0)  # Unpredictable
		_:
			return base_consumption
