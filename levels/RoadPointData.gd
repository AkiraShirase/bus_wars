# RoadPointData.gd - Resource for storing point properties
extends Resource
class_name RoadPointData

@export var gravity: int = 50  # 1-100, affects acceleration
@export var health: float = 100.0  # Road condition
@export var pollution: float = 0.0  # Environmental factor
@export var sewer_percent: float = 100.0  # Infrastructure quality

func _init(p_gravity: int = 50, p_health: float = 100.0, p_pollution: float = 0.0, p_sewer: float = 100.0):
	gravity = p_gravity
	health = p_health
	pollution = p_pollution
	sewer_percent = p_sewer
