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

func get_source_name() -> String:
	match source_type:
		SourceType.STEAM: return "steam"
		SourceType.GAS: return "gas"
		SourceType.HYDROGEN: return "hydrogen"
		SourceType.BATTERY: return "battery"
		SourceType.ALIEN: return "alien"
		SourceType.PSYCHIC: return "psychic"
		SourceType.CHAOS: return "chaos"
		_: return "unknown"

func get_properties() -> Dictionary:
	match source_type:
		SourceType.STEAM:
			return {
				"weight": 500.0,
				"complexity": 0.3,
				"reliability": 0.8,
				"environmental_impact": 0.8,
				"startup_time": 10.0,
				"special_features": ["vintage_charm", "whistle"]
			}
		SourceType.GAS:
			return {
				"weight": 200.0,
				"complexity": 0.5,
				"reliability": 0.9,
				"environmental_impact": 0.6,
				"startup_time": 1.0,
				"special_features": ["common", "easy_refuel"]
			}
		SourceType.HYDROGEN:
			return {
				"weight": 300.0,
				"complexity": 0.7,
				"reliability": 0.85,
				"environmental_impact": 0.1,
				"startup_time": 2.0,
				"special_features": ["clean", "explosive_risk"]
			}
		SourceType.BATTERY:
			return {
				"weight": 600.0,
				"complexity": 0.6,
				"reliability": 0.95,
				"environmental_impact": 0.2,
				"startup_time": 0.1,
				"special_features": ["silent", "regenerative"]
			}
		SourceType.ALIEN:
			return {
				"weight": 100.0,
				"complexity": 0.95,
				"reliability": 0.99,
				"environmental_impact": -0.2,  # Actually helps environment
				"startup_time": 0.0,
				"special_features": ["antigrav", "self_repairing", "telepathic"]
			}
		SourceType.PSYCHIC:
			return {
				"weight": 50.0,
				"complexity": 0.8,
				"reliability": 0.7,  # Depends on driver's mental state
				"environmental_impact": 0.0,
				"startup_time": 3.0,  # Meditation required
				"special_features": ["mind_powered", "emotion_sensitive"]
			}
		SourceType.CHAOS:
			return {
				"weight": randf_range(10.0, 1000.0),  # Changes randomly
				"complexity": 1.0,
				"reliability": chaos_stability,
				"environmental_impact": randf_range(-1.0, 1.0),
				"startup_time": randf_range(0.0, 20.0),
				"special_features": ["unpredictable", "reality_warping", "lucky"]
			}
		_:
			return {}

func consume_fuel(amount: float, delta: float) -> bool:
	if source_type == SourceType.PSYCHIC:
		# Psychic power doesn't use fuel, uses mental energy
		return psychic_resonance > 0.3
	
	if current_fuel >= amount * delta:
		current_fuel -= amount * delta
		return true
	else:
		current_fuel = 0.0
		return false

func refuel(delta: float):
	match source_type:
		SourceType.STEAM, SourceType.GAS, SourceType.HYDROGEN:
			current_fuel = min(current_fuel + refuel_rate * delta, fuel_capacity)
		SourceType.BATTERY:
			# Batteries charge differently
			current_fuel = min(current_fuel + refuel_rate * delta * 0.5, fuel_capacity)
		SourceType.ALIEN:
			# Self-regenerating
			current_fuel = min(current_fuel + delta * 5.0, fuel_capacity)
			alien_core_health = min(alien_core_health + delta * 2.0, 100.0)
		SourceType.PSYCHIC:
			# Meditation increases psychic resonance
			psychic_resonance = min(psychic_resonance + delta * 0.1, 1.0)
		SourceType.CHAOS:
			# Who knows what happens
			current_fuel = randf_range(0.0, fuel_capacity)

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
