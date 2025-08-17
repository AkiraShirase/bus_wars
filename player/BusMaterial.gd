# BusMaterial.gd
extends Resource
class_name BusMaterial

enum MaterialType {
	STEEL,
	ALUMINUM,
	CARBON_FIBER,
	TITANIUM,
	WOOD,
	CRYSTAL,
	DARK_MATTER
}

@export var material_type: MaterialType = MaterialType.STEEL
@export var base_weight_multiplier: float = 1.0
@export var durability: float = 100.0
@export var corrosion_resistance: float = 50.0

# Power source compatibility modifiers
var power_source_modifiers = {
	"steam": {"weight": 1.2, "durability": 1.1},
	"gas": {"weight": 1.0, "durability": 1.0},
	"hydrogen": {"weight": 0.9, "durability": 1.0},
	"battery": {"weight": 1.1, "durability": 0.95},
	"alien": {"weight": 0.7, "durability": 1.5},
	"psychic": {"weight": 0.8, "durability": 1.2},
	"chaos": {"weight": 1.3, "durability": 0.8}
}

func get_material_properties() -> Dictionary:
	match material_type:
		MaterialType.STEEL:
			return {"weight": 1.0, "strength": 0.8, "cost": 0.5}
		MaterialType.ALUMINUM:
			return {"weight": 0.7, "strength": 0.6, "cost": 0.7}
		MaterialType.CARBON_FIBER:
			return {"weight": 0.5, "strength": 0.9, "cost": 1.0}
		MaterialType.TITANIUM:
			return {"weight": 0.6, "strength": 1.0, "cost": 1.5}
		MaterialType.WOOD:
			return {"weight": 0.4, "strength": 0.3, "cost": 0.2}
		MaterialType.CRYSTAL:
			return {"weight": 0.8, "strength": 0.7, "cost": 2.0}
		MaterialType.DARK_MATTER:
			return {"weight": 0.1, "strength": 2.0, "cost": 10.0}
		_:
			return {"weight": 1.0, "strength": 1.0, "cost": 1.0}

func get_weight_modifier(power_source: String) -> float:
	var base_props = get_material_properties()
	var power_mod = 1.0
	
	if power_source in power_source_modifiers:
		power_mod = power_source_modifiers[power_source]["weight"]
	
	return base_props["weight"] * base_weight_multiplier * power_mod

func get_durability_modifier(power_source: String) -> float:
	var base_props = get_material_properties()
	var power_mod = 1.0
	
	if power_source in power_source_modifiers:
		power_mod = power_source_modifiers[power_source]["durability"]
	
	return base_props["strength"] * power_mod
