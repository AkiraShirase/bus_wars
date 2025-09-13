# PassengerSection.gd
extends Resource
class_name PassengerSection

@export var section_count: int = 1
@export var seats_per_section: int = 30
@export var standing_room_per_section: int = 10
@export var luxury_level: float = 0.5  # 0.0 = basic, 1.0 = luxury
@export var weight_per_section: float = 2000.0  # kg

# Current passengers
var current_passengers: int = 0
var passenger_satisfaction: float = 100.0

func get_total_capacity() -> int:
	var seat_capacity = section_count * seats_per_section
	var standing_capacity = section_count * standing_room_per_section
	
	# Luxury buses have less standing room
	standing_capacity = int(standing_capacity * (1.0 - luxury_level * 0.5))
	
	return seat_capacity + standing_capacity

func get_total_weight() -> float:
	var base_weight = section_count * weight_per_section
	var passenger_weight = current_passengers * 70.0  # Average 70kg per passenger
	
	# Luxury adds weight (better seats, amenities)
	var luxury_modifier = 1.0 + (luxury_level * 0.3)
	
	return (base_weight * luxury_modifier) + passenger_weight

func add_passengers(count: int) -> int:
	var capacity = get_total_capacity()
	var available_space = capacity - current_passengers
	var added = min(count, available_space)
	
	current_passengers += added
	return added

func remove_passengers(count: int) -> int:
	var removed = min(count, current_passengers)
	current_passengers -= removed
	return removed

func update_satisfaction(delta: float, speed: float, acceleration: float):
	# Factors affecting satisfaction
	var comfort_factor = luxury_level
	var crowding_factor = 1.0 - (float(current_passengers) / float(get_total_capacity()))
	var smooth_ride_factor = 1.0 - (abs(acceleration) / 1000.0)  # Penalize harsh acceleration
	
	# Calculate satisfaction change
	var satisfaction_delta = (comfort_factor + crowding_factor + smooth_ride_factor) / 3.0
	satisfaction_delta = (satisfaction_delta - 0.5) * delta * 10.0  # Rate of change
	
	passenger_satisfaction = clamp(passenger_satisfaction + satisfaction_delta, 0.0, 100.0)

func get_weight_distribution() -> float:
	# Returns center of mass offset based on passenger distribution
	# Simplified: assumes even distribution
	return 0.0
