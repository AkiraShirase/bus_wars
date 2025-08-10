@tool
extends Line2D
class_name IsometricRoad

# Road properties
@export_group("Road Settings")
@export var road_width: float = 60.0:
	set(value):
		road_width = value
		width = value
		queue_redraw()

@export var road_color: Color = Color(0.3, 0.3, 0.3):
	set(value):
		road_color = value
		default_color = value

@export var show_sidewalks: bool = true:
	set(value):
		show_sidewalks = value
		update_sidewalks()

@export var sidewalk_width: float = 10.0:
	set(value):
		sidewalk_width = value
		update_sidewalks()

@export var sidewalk_color: Color = Color(0.6, 0.6, 0.6):
	set(value):
		sidewalk_color = value
		update_sidewalks()

# Isometric settings
@export_group("Isometric")
@export var snap_to_isometric: bool = true:
	set(value):
		snap_to_isometric = value
		if value:
			snap_all_points()

@export var isometric_angle: float = 26.565:
	set(value):
		isometric_angle = value
		if snap_to_isometric:
			snap_all_points()

@export var grid_size: float = 32.0:
	set(value):
		grid_size = value
		if snap_to_isometric:
			snap_all_points()

# Drawing helpers
@export_group("Drawing Helpers")
@export var show_grid: bool = true:
	set(value):
		show_grid = value
		queue_redraw()

@export var grid_color: Color = Color(0.5, 0.5, 0.5, 0.3)

@export var show_direction_handles: bool = true:
	set(value):
		show_direction_handles = value
		queue_redraw()

@export var align_ends_to_grid: bool = true:
	set(value):
		align_ends_to_grid = value
		update_road_geometry()

@export var show_end_caps: bool = true:
	set(value):
		show_end_caps = value
		update_road_geometry()

# Road markings
@export_group("Road Markings")
@export var show_center_line: bool = true:
	set(value):
		show_center_line = value
		update_markings()

@export var center_line_color: Color = Color.YELLOW:
	set(value):
		center_line_color = value
		update_markings()

@export var center_line_dashed: bool = true:
	set(value):
		center_line_dashed = value
		update_markings()

# Child nodes for additional visuals
var sidewalk_left: Line2D
var sidewalk_right: Line2D
var center_line: Line2D
var marking_lines: Array[Line2D] = []
var end_cap_start: Polygon2D
var end_cap_end: Polygon2D

func _enter_tree():
	# Find existing child nodes
	if has_node("SidewalkLeft"):
		sidewalk_left = get_node("SidewalkLeft")
	if has_node("SidewalkRight"):
		sidewalk_right = get_node("SidewalkRight")
	if has_node("EndCapStart"):
		end_cap_start = get_node("EndCapStart")
	if has_node("EndCapEnd"):
		end_cap_end = get_node("EndCapEnd")

func _ready():
	# Set initial properties
	width = road_width
	default_color = road_color
	joint_mode = Line2D.LINE_JOINT_ROUND
	# cap_mode is only available in newer versions
	if "cap_mode" in self:
		set("cap_mode", Line2D.LINE_CAP_ROUND)
	
	# Create child elements for both editor and game
	setup_child_elements()

func setup_child_elements():
	# Create sidewalks if they don't exist
	if not sidewalk_left:
		sidewalk_left = Line2D.new()
		sidewalk_left.name = "SidewalkLeft"
		add_child(sidewalk_left)
		# Make sure the node is saved with the scene
		if Engine.is_editor_hint():
			sidewalk_left.owner = get_tree().edited_scene_root
		
	if not sidewalk_right:
		sidewalk_right = Line2D.new()
		sidewalk_right.name = "SidewalkRight"
		add_child(sidewalk_right)
		# Make sure the node is saved with the scene
		if Engine.is_editor_hint():
			sidewalk_right.owner = get_tree().edited_scene_root
	
	# Create end caps for proper isometric cuts
	if not end_cap_start:
		end_cap_start = Polygon2D.new()
		end_cap_start.name = "EndCapStart"
		end_cap_start.color = road_color
		add_child(end_cap_start)
		if Engine.is_editor_hint():
			end_cap_start.owner = get_tree().edited_scene_root
	
	if not end_cap_end:
		end_cap_end = Polygon2D.new()
		end_cap_end.name = "EndCapEnd"
		end_cap_end.color = road_color
		add_child(end_cap_end)
		if Engine.is_editor_hint():
			end_cap_end.owner = get_tree().edited_scene_root
	
	update_sidewalks()
	update_markings()
	update_road_geometry()

func _draw():
	if not Engine.is_editor_hint():
		return
	
	# Draw isometric grid
	if show_grid:
		draw_isometric_grid()
	
	# Draw direction handles at each point
	if show_direction_handles and points.size() > 0:
		for i in range(points.size()):
			draw_point_handle(i)

func draw_isometric_grid():
	var viewport_size = get_viewport_rect().size
	var grid_extent = viewport_size.length() * 2
	
	# Draw isometric grid lines
	# Lines going "right" (positive X in isometric)
	var angle_right = deg_to_rad(isometric_angle)
	var angle_left = deg_to_rad(180 - isometric_angle)
	
	for i in range(-50, 50):
		var offset = i * grid_size
		
		# Right-facing lines
		var start_r = Vector2(-grid_extent, 0) + Vector2(0, offset)
		var end_r = Vector2(grid_extent, 0) + Vector2(0, offset)
		start_r = start_r.rotated(angle_right)
		end_r = end_r.rotated(angle_right)
		draw_line(start_r - global_position, end_r - global_position, grid_color, 1.0)
		
		# Left-facing lines
		var start_l = Vector2(-grid_extent, 0) + Vector2(0, offset)
		var end_l = Vector2(grid_extent, 0) + Vector2(0, offset)
		start_l = start_l.rotated(angle_left)
		end_l = end_l.rotated(angle_left)
		draw_line(start_l - global_position, end_l - global_position, grid_color, 1.0)

func draw_point_handle(index: int):
	var point = points[index]
	
	# Draw point
	draw_circle(point, 5, Color.WHITE)
	draw_circle(point, 3, Color.RED)
	
	# Draw directional arrows for isometric axes
	if snap_to_isometric:
		var iso_right = Vector2.RIGHT.rotated(deg_to_rad(isometric_angle))
		var iso_down = Vector2.RIGHT.rotated(deg_to_rad(isometric_angle + 90))
		
		# Draw arrows
		draw_line(point, point + iso_right * 30, Color.RED, 2)
		draw_line(point, point + iso_down * 30, Color.GREEN, 2)
		
		# Arrow heads
		var arrow_size = 8
		var arrow_angle = 150
		
		# Red arrow head
		var red_tip = point + iso_right * 30
		draw_line(red_tip, red_tip + iso_right.rotated(deg_to_rad(arrow_angle)) * arrow_size, Color.RED, 2)
		draw_line(red_tip, red_tip + iso_right.rotated(deg_to_rad(-arrow_angle)) * arrow_size, Color.RED, 2)
		
		# Green arrow head  
		var green_tip = point + iso_down * 30
		draw_line(green_tip, green_tip + iso_down.rotated(deg_to_rad(arrow_angle)) * arrow_size, Color.GREEN, 2)
		draw_line(green_tip, green_tip + iso_down.rotated(deg_to_rad(-arrow_angle)) * arrow_size, Color.GREEN, 2)

func snap_all_points():
	for i in range(points.size()):
		points[i] = snap_to_isometric_grid(points[i])
	
	update_sidewalks()
	update_markings()

func snap_to_isometric_grid(point: Vector2) -> Vector2:
	if not snap_to_isometric:
		return point
	
	# Convert to isometric grid coordinates
	var iso_x = point.x * cos(deg_to_rad(isometric_angle)) + point.y * sin(deg_to_rad(isometric_angle))
	var iso_y = -point.x * sin(deg_to_rad(isometric_angle)) + point.y * cos(deg_to_rad(isometric_angle))
	
	# Snap to grid
	iso_x = round(iso_x / grid_size) * grid_size
	iso_y = round(iso_y / grid_size) * grid_size
	
	# Convert back to world coordinates
	var snapped_x = iso_x * cos(deg_to_rad(isometric_angle)) - iso_y * sin(deg_to_rad(isometric_angle))
	var snapped_y = iso_x * sin(deg_to_rad(isometric_angle)) + iso_y * cos(deg_to_rad(isometric_angle))
	
	return Vector2(snapped_x, snapped_y)

func update_sidewalks():
	if not sidewalk_left or not sidewalk_right:
		return
	
	sidewalk_left.visible = show_sidewalks
	sidewalk_right.visible = show_sidewalks
	
	if not show_sidewalks:
		return
	
	# Clear sidewalk points
	sidewalk_left.clear_points()
	sidewalk_right.clear_points()
	
	if points.size() < 2:
		return
	
	# Set sidewalk properties
	sidewalk_left.width = sidewalk_width
	sidewalk_right.width = sidewalk_width
	sidewalk_left.default_color = sidewalk_color
	sidewalk_right.default_color = sidewalk_color
	sidewalk_left.z_index = z_index - 1
	sidewalk_right.z_index = z_index - 1
	
	# Calculate sidewalk points
	for i in range(points.size()):
		var point = points[i]
		var direction = Vector2.ZERO
		var perpendicular = Vector2.ZERO
		
		if i == 0:
			# First point
			direction = (points[i + 1] - points[i]).normalized()
		elif i == points.size() - 1:
			# Last point
			direction = (points[i] - points[i - 1]).normalized()
		else:
			# Middle points - average of both directions
			var dir1 = (points[i] - points[i - 1]).normalized()
			var dir2 = (points[i + 1] - points[i]).normalized()
			direction = ((dir1 + dir2) / 2).normalized()
		
		perpendicular = Vector2(-direction.y, direction.x)
		
		# Add offset points
		var offset = (road_width / 2 + sidewalk_width / 2) * perpendicular
		sidewalk_left.add_point(point + offset)
		sidewalk_right.add_point(point - offset)

func update_markings():
	# Clear existing markings
	for line in marking_lines:
		if is_instance_valid(line):
			line.queue_free()
	marking_lines.clear()
	
	if not show_center_line or points.size() < 2:
		return
	
	# Create center line
	if center_line_dashed:
		# Create dashed line
		var total_length = 0.0
		var segment_lengths = []
		
		# Calculate total length
		for i in range(points.size() - 1):
			var length = points[i].distance_to(points[i + 1])
			segment_lengths.append(length)
			total_length += length
		
		# Create dashes
		var dash_length = 20.0
		var gap_length = 15.0
		var current_distance = 0.0
		var current_segment = 0
		var segment_start_distance = 0.0
		
		while current_distance < total_length and current_segment < segment_lengths.size():
			var dash_start_distance = current_distance
			var dash_end_distance = min(current_distance + dash_length, total_length)
			
			# Find points for this dash
			var start_point = get_point_at_distance(dash_start_distance)
			var end_point = get_point_at_distance(dash_end_distance)
			
			# Create dash line
			var dash = Line2D.new()
			dash.add_point(start_point)
			dash.add_point(end_point)
			dash.width = 3.0
			dash.default_color = center_line_color
			dash.z_index = z_index + 1
			add_child(dash)
			marking_lines.append(dash)
			
			current_distance += dash_length + gap_length
	else:
		# Create solid line
		var line = Line2D.new()
		line.points = points
		line.width = 3.0
		line.default_color = center_line_color
		line.z_index = z_index + 1
		add_child(line)
		marking_lines.append(line)

func update_road_geometry():
	if not end_cap_start or not end_cap_end:
		return
	
	end_cap_start.visible = show_end_caps and align_ends_to_grid
	end_cap_end.visible = show_end_caps and align_ends_to_grid
	
	if not show_end_caps or not align_ends_to_grid or points.size() < 2:
		return
	
	# Update end cap colors
	end_cap_start.color = road_color
	end_cap_end.color = road_color
	
	# Calculate isometric grid angles
	var iso_angle_1 = deg_to_rad(isometric_angle)
	var iso_angle_2 = deg_to_rad(isometric_angle + 90)
	var iso_angle_3 = deg_to_rad(isometric_angle + 180)
	var iso_angle_4 = deg_to_rad(isometric_angle + 270)
	
	# Start cap
	var start_point = points[0]
	var start_direction = (points[1] - points[0]).normalized()
	var start_perpendicular = Vector2(-start_direction.y, start_direction.x)
	
	# Find best isometric angle for start cap
	var start_cap_angle = find_best_isometric_angle(start_direction)
	var start_cap_dir = Vector2.from_angle(start_cap_angle)
	
	# Create start cap polygon
	var start_cap_points = PackedVector2Array()
	var half_width = road_width / 2
	
	# Calculate cap points
	var p1 = start_point + start_perpendicular * half_width
	var p2 = start_point - start_perpendicular * half_width
	var p3 = p2 - start_cap_dir * 10  # Extend slightly for clean cut
	var p4 = p1 - start_cap_dir * 10
	
	start_cap_points.append(p1)
	start_cap_points.append(p2)
	start_cap_points.append(p3)
	start_cap_points.append(p4)
	
	end_cap_start.polygon = start_cap_points
	
	# End cap
	var end_point = points[points.size() - 1]
	var end_direction = (points[points.size() - 1] - points[points.size() - 2]).normalized()
	var end_perpendicular = Vector2(-end_direction.y, end_direction.x)
	
	# Find best isometric angle for end cap
	var end_cap_angle = find_best_isometric_angle(-end_direction)
	var end_cap_dir = Vector2.from_angle(end_cap_angle)
	
	# Create end cap polygon
	var end_cap_points = PackedVector2Array()
	
	# Calculate cap points
	var p5 = end_point + end_perpendicular * half_width
	var p6 = end_point - end_perpendicular * half_width
	var p7 = p6 - end_cap_dir * 10
	var p8 = p5 - end_cap_dir * 10
	
	end_cap_points.append(p5)
	end_cap_points.append(p6)
	end_cap_points.append(p7)
	end_cap_points.append(p8)
	
	end_cap_end.polygon = end_cap_points

func find_best_isometric_angle(direction: Vector2) -> float:
	# Get the angle of the direction
	var dir_angle = direction.angle()
	
	# Define isometric grid angles (8 directions)
	var grid_angles = []
	for i in range(8):
		grid_angles.append(deg_to_rad(isometric_angle + i * 45))
	
	# Find closest grid angle
	var best_angle = grid_angles[0]
	var min_diff = abs(angle_difference(dir_angle, grid_angles[0]))
	
	for angle in grid_angles:
		var diff = abs(angle_difference(dir_angle, angle))
		if diff < min_diff:
			min_diff = diff
			best_angle = angle
	
	return best_angle

func angle_difference(a: float, b: float) -> float:
	var diff = b - a
	while diff > PI:
		diff -= TAU
	while diff < -PI:
		diff += TAU
	return diff

func get_point_at_distance(distance: float) -> Vector2:
	if points.size() < 2:
		return Vector2.ZERO
	
	var current_distance = 0.0
	
	for i in range(points.size() - 1):
		var segment_length = points[i].distance_to(points[i + 1])
		
		if current_distance + segment_length >= distance:
			# Point is in this segment
			var segment_distance = distance - current_distance
			var t = segment_distance / segment_length
			return points[i].lerp(points[i + 1], t)
		
		current_distance += segment_length
	
	# If we get here, return the last point
	return points[points.size() - 1]

# Helper function to add a point with isometric snapping
func add_isometric_point(world_pos: Vector2):
	var local_pos = to_local(world_pos)
	if snap_to_isometric:
		local_pos = snap_to_isometric_grid(local_pos)
	add_point(local_pos)
	update_sidewalks()
	update_markings()
