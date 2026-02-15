extends Node
class_name PowerSourceFactory

func create(source_type: PowerSource.SourceType) -> PowerSource:
	var power_source = PowerSource.new()
	power_source.source_type = source_type

	# Set default properties based on source type
	match source_type:
		PowerSource.SourceType.STEAM:
			power_source.fuel_capacity = 150.0
			power_source.current_fuel = 150.0
			power_source.refuel_rate = 30.0
		PowerSource.SourceType.GAS:
			power_source.fuel_capacity = 100.0
			power_source.current_fuel = 100.0
			power_source.refuel_rate = 50.0
		PowerSource.SourceType.HYDROGEN:
			power_source.fuel_capacity = 120.0
			power_source.current_fuel = 120.0
			power_source.refuel_rate = 40.0
		PowerSource.SourceType.BATTERY:
			power_source.fuel_capacity = 200.0
			power_source.current_fuel = 200.0
			power_source.refuel_rate = 25.0
		PowerSource.SourceType.ALIEN:
			power_source.fuel_capacity = 300.0
			power_source.current_fuel = 300.0
			power_source.refuel_rate = 100.0
			power_source.alien_core_health = 100.0
		PowerSource.SourceType.PSYCHIC:
			power_source.fuel_capacity = 100.0
			power_source.current_fuel = 100.0
			power_source.refuel_rate = 20.0
			power_source.psychic_resonance = 1.0
		PowerSource.SourceType.CHAOS:
			power_source.fuel_capacity = randf_range(50.0, 250.0)
			power_source.current_fuel = power_source.fuel_capacity
			power_source.refuel_rate = randf_range(10.0, 100.0)
			power_source.chaos_stability = randf_range(0.3, 0.7)

	return power_source
