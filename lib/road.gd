extends Node2D
class_name IsometricRoadSystem

# Road configuration
@export var road_width: float = 60.0
@export var lane_width: float = 30.0
@export var sidewalk_width: float = 10.0
@export var isometric_angle: float = 26.565  # Standard isometric angle

# Visual settings
@export_group("Colors")
@export var road_color: Color = Color(0.3, 0.3, 0.3)
@export var sidewalk_color: Color = Color(0.6, 0.6, 0.6)
@export var marking_color: Color = Color(1.0, 1.0, 1.0)
@export var center_line_color: Color = Color.YELLOW

# Grid settings for isometric layout
@export_group("Grid")
@export var grid_size: Vector2i = Vector2i(10, 10)  # Number of intersections
@export var block_size: Vector2 = Vector2(200, 200)  # Size between intersections

# Road network storage
var roads: Array[Line2D] = []
var sidewalks: Array[Line2D] = []
var road_markings: Array[Line2D] = []
var intersections: Array[Vector2] = []
var road_graph: Dictionary = {}  # For pathfinding

func _ready():
	generate_road_network()

func generate_road_network():
	clear_roads()
	generate_grid_roads()
	add_road_markings()
	build_road_graph()

func clear_roads():
	for road in roads:
		road.queue_free()
	roads.clear()
	
	for sidewalk in sidewalks:
		sidewalk.queue_free()
	sidewalks.clear()
	
	for marking in road_markings:
		marking.queue_free()
	road_markings.clear()
	
	intersections.clear()
	road_graph.clear()

func generate_grid_roads():
	# Generate intersection points in isometric space
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var iso_pos = grid_to_isometric(Vector2(x, y))
			intersections.append(iso_pos)
	
	# Create horizontal roads (along X axis in grid)
	for y in range(grid_size.y):
		for x in range(grid_size.x - 1):
			var start = grid_to_isometric(Vector2(x, y))
			var end = grid_to_isometric(Vector2(x + 1, y))
			create_road_segment(start, end)
	
	# Create vertical roads (along Y axis in grid)
	for x in range(grid_size.x):
		for y in range(grid_size.y - 1):
			var start = grid_to_isometric(Vector2(x, y))
			var end = grid_to_isometric(Vector2(x, y + 1))
			create_road_segment(start, end)
	
	# Add some diagonal roads for variety
	if grid_size.x > 3 and grid_size.y > 3:
		# Main diagonal
		create_road_segment(
			grid_to_isometric(Vector2(0, 0)),
			grid_to_isometric(Vector2(min(grid_size.x, grid_size.y) - 1, min(grid_size.x, grid_size.y) - 1))
		)

func create_road_segment(start: Vector2, end: Vector2):
	# Create main road
	var road = Line2D.new()
	road.add_point(start)
	road.add_point(end)
	road.width = road_width
	road.default_color = road_color
	road.joint_mode = Line2D.LINE_JOINT_ROUND
	road.cap_mode = Line2D.LINE_CAP_ROUND
	add_child(road)
	roads.append(road)
	
	# Create sidewalks (parallel lines on both sides)
	var direction = (end - start).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)
	
	for side in [-1, 1]:
		var sidewalk = Line2D.new()
		var offset = perpendicular * (road_width / 2 + sidewalk_width / 2) * side
		sidewalk.add_point(start + offset)
		sidewalk.add_point(end + offset)
		sidewalk.width = sidewalk_width
		sidewalk.default_color = sidewalk_color
		sidewalk.z_index = -1  # Behind the road
		add_child(sidewalk)
		sidewalks.append(sidewalk)

func add_road_markings():
	for road in roads:
		if road.points.size() < 2:
			continue
		
		var start = road.points[0]
		var end = road.points[1]
		var direction = (end - start).normalized()
		var perpendicular = Vector2(-direction.y, direction.x)
		var road_length = start.distance_to(end)
		
		# Center line (dashed)
		var center_line = Line2D.new()
		var dash_length = 20.0
		var gap_length = 15.0
		var current_pos = 0.0
		
		while current_pos < road_length:
			var dash_start = start + direction * current_pos
			var dash_end = start + direction * min(current_pos + dash_length, road_length)
			
			# Create individual dash
			var dash = Line2D.new()
			dash.add_point(dash_start)
			dash.add_point(dash_end)
			dash.width = 3.0
			dash.default_color = center_line_color
			dash.z_index = 1
			add_child(dash)
			road_markings.append(dash)
			
			current_pos += dash_length + gap_length
		
		# Lane markings (if wide enough for multiple lanes)
		if road_width >= lane_width * 2:
			# Edge lines (solid)
			for side in [-1, 1]:
				var edge_line = Line2D.new()
				var offset = perpendicular * (road_width / 2 - 5) * side
				edge_line.add_point(start + offset)
				edge_line.add_point(end + offset)
				edge_line.width = 2.0
				edge_line.default_color = marking_color
				edge_line.z_index = 1
				add_child(edge_line)
				road_markings.append(edge_line)

func grid_to_isometric(grid_pos: Vector2) -> Vector2:
	# Convert grid coordinates to isometric world coordinates
	var x = (grid_pos.x - grid_pos.y) * block_size.x / 2
	var y = (grid_pos.x + grid_pos.y) * block_size.y / 2
	return Vector2(x, y)

func isometric_to_grid(iso_pos: Vector2) -> Vector2:
	# Convert isometric world coordinates to grid coordinates
	var x = (iso_pos.x / (block_size.x / 2) + iso_pos.y / (block_size.y / 2)) / 2
	var y = (iso_pos.y / (block_size.y / 2) - iso_pos.x / (block_size.x / 2)) / 2
	return Vector2(x, y)

func build_road_graph():
	# Build a graph for pathfinding
	road_graph.clear()
	
	# Initialize all intersections
	for intersection in intersections:
		road_graph[intersection] = []
	
	# Connect intersections based on roads
	for road in roads:
		if road.points.size() >= 2:
			var start = road.points[0]
			var end = road.points[1]
			
			# Find closest intersections
			var start_intersection = find_closest_intersection(start)
			var end_intersection = find_closest_intersection(end)
			
			if start_intersection and end_intersection:
				# Add bidirectional connection
				if not end_intersection in road_graph[start_intersection]:
					road_graph[start_intersection].append(end_intersection)
				if not start_intersection in road_graph[end_intersection]:
					road_graph[end_intersection].append(start_intersection)

func find_closest_intersection(pos: Vector2) -> Vector2:
	var closest = intersections[0] if intersections.size() > 0 else Vector2.ZERO
	var min_dist = pos.distance_to(closest)
	
	for intersection in intersections:
		var dist = pos.distance_to(intersection)
		if dist < min_dist:
			min_dist = dist
			closest = intersection
	
	return closest if min_dist < 10.0 else pos

func get_nearest_road_point(world_pos: Vector2) -> Vector2:
	# Find the nearest point on any road to the given position
	var nearest_point = world_pos
	var min_distance = INF
	
	for road in roads:
		if road.points.size() >= 2:
			var point = get_closest_point_on_line(world_pos, road.points[0], road.points[1])
			var distance = world_pos.distance_to(point)
			
			if distance < min_distance:
				min_distance = distance
				nearest_point = point
	
	return nearest_point

func get_closest_point_on_line(point: Vector2, line_start: Vector2, line_end: Vector2) -> Vector2:
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_len = line_vec.length()
	
	if line_len == 0:
		return line_start
	
	var line_unitvec = line_vec / line_len
	var proj_length = clamp(point_vec.dot(line_unitvec), 0.0, line_len)
	
	return line_start + line_unitvec * proj_length

func is_on_road(world_pos: Vector2, tolerance: float = 30.0) -> bool:
	var nearest = get_nearest_road_point(world_pos)
	return world_pos.distance_to(nearest) <= tolerance

# Get road direction at a given position
func get_road_direction(world_pos: Vector2) -> Vector2:
	var nearest_road = null
	var min_distance = INF
	
	for road in roads:
		if road.points.size() >= 2:
			var point = get_closest_point_on_line(world_pos, road.points[0], road.points[1])
			var distance = world_pos.distance_to(point)
			
			if distance < min_distance:
				min_distance = distance
				nearest_road = road
	
	if nearest_road and nearest_road.points.size() >= 2:
		return (nearest_road.points[1] - nearest_road.points[0]).normalized()
	
	return Vector2.RIGHT.rotated(deg_to_rad(isometric_angle))

# Debug visualization
func draw_debug_intersections():
	for intersection in intersections:
		draw_circle(intersection, 10, Color.RED)
