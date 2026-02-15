# PowerSource.gd
extends Resource
class_name PowerSource

enum SourceType {
	STEAM,
	GAS,
	HYDROGEN,
	BATTERY,
	ALIEN,
	PSYCHIC,
	CHAOS
}

@export var source_type: SourceType = SourceType.GAS
@export var fuel_capacity: float = 100.0
@export var current_fuel: float = 100.0
@export var refuel_rate: float = 50.0  # Units per second when refueling

# Special properties for exotic power sources
@export var psychic_resonance: float = 1.0  # For psychic power
@export var chaos_stability: float = 0.5  # For chaos power (0 = pure chaos, 1 = stable)
@export var alien_core_health: float = 100.0  # For alien power

func get_special_effects() -> Dictionary:
	var effects = {}
	
	match source_type:
		SourceType.STEAM:
			effects["particle"] = "steam_puff"
			effects["sound"] = "choo_choo"
		SourceType.ALIEN:
			effects["particle"] = "antigrav_glow"
			effects["aura"] = true
		SourceType.PSYCHIC:
			effects["particle"] = "mind_waves"
			effects["screen_effect"] = "psychic_distortion"
		SourceType.CHAOS:
			effects["particle"] = ["rainbow", "glitch", "explosions", "butterflies"][randi() % 4]
			effects["random_teleport_chance"] = 0.001
	
	return effects

func update_special_properties(delta: float, driver_mood: float = 0.5):
	match source_type:
		SourceType.PSYCHIC:
			# Psychic resonance affected by driver mood
			psychic_resonance += (driver_mood - 0.5) * delta * 0.2
			psychic_resonance = clamp(psychic_resonance, 0.0, 1.0)
		SourceType.CHAOS:
			# Chaos randomly shifts stability
			chaos_stability += randf_range(-0.1, 0.1) * delta
			chaos_stability = clamp(chaos_stability, 0.0, 1.0)
		SourceType.ALIEN:
			# Alien core slowly degrades without maintenance
			alien_core_health -= delta * 0.1
			alien_core_health = clamp(alien_core_health, 0.0, 100.0)
