# BusDebugUI.gd
extends PanelContainer
class_name BusDebugUI

enum WindowPosition { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, CUSTOM }

# Window settings
@export_group("Window")
@export var window_title: String = "Bus Debug Info"
@export var draggable: bool = true
@export var resizable: bool = true
@export var default_position: WindowPosition = WindowPosition.TOP_LEFT
@export var custom_position: Vector2 = Vector2(10, 10)
@export var margin: Vector2 = Vector2(10, 10)  # Margin from screen edges
@export var start_size: Vector2 = Vector2(300, 400)
@export var auto_resize: bool = true

# Display settings
@export_group("Display Options")
@export var show_vectors_section: bool = true
@export var show_performance_section: bool = true
@export var show_components_section: bool = true
@export var show_special_section: bool = true
@export var update_rate: float = 0.1  # Update every 0.1 seconds

# Style settings
@export_group("Style")
@export var panel_style: StyleBoxFlat
@export var header_color: Color = Color(0.2, 0.2, 0.2, 0.9)
@export var background_color: Color = Color(0.1, 0.1, 0.1, 0.8)
@export var text_color: Color = Color.WHITE
@export var value_color: Color = Color.CYAN
@export var warning_color: Color = Color.YELLOW
@export var critical_color: Color = Color.RED

@export var bus: GameVehicle = null

# UI Elements
var title_bar: Panel
var title_label: Label
var close_button: Button
var content_container: VBoxContainer
var resize_handle: TextureRect

# Sections
var vector_section: VBoxContainer
var performance_section: VBoxContainer
var component_section: VBoxContainer
var special_section: VBoxContainer

# Labels for dynamic content
var speed_label: HBoxContainer
var steer_label: HBoxContainer
var fuel_label: HBoxContainer
var passenger_label: HBoxContainer
var gravity_label: HBoxContainer
var tire_label: HBoxContainer
var engine_label: HBoxContainer
var weight_label: HBoxContainer

# Reference to bus
#var bus: GameVehicle = null

# Window state
var is_dragging: bool = false
var is_resizing: bool = false
var drag_offset: Vector2
var update_timer: float = 0.0

func _ready():
	# Setup panel style
	setup_panel_style()
	
	# Create UI structure
	create_ui_structure()
	
	# Set initial size
	custom_minimum_size = start_size
	size = start_size
	
	# Set initial position based on setting
	set_window_position(default_position)
	
	# Find bus
	find_bus()
	
	# Make sure we're on top
	z_index = 100
	
	# Connect to viewport size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func setup_panel_style():
	if not panel_style:
		panel_style = StyleBoxFlat.new()
		panel_style.bg_color = background_color
		panel_style.border_color = header_color
		panel_style.set_border_width_all(2)
		panel_style.set_corner_radius_all(5)
	
	add_theme_stylebox_override("panel", panel_style)

func set_window_position(position_preset: WindowPosition):
	var viewport_size = get_viewport().get_visible_rect().size
	
	match position_preset:
		WindowPosition.TOP_LEFT:
			position = margin
		WindowPosition.TOP_RIGHT:
			position = Vector2(viewport_size.x - size.x - margin.x, margin.y)
		WindowPosition.BOTTOM_LEFT:
			position = Vector2(margin.x, viewport_size.y - size.y - margin.y)
		WindowPosition.BOTTOM_RIGHT:
			position = Vector2(viewport_size.x - size.x - margin.x, viewport_size.y - size.y - margin.y)
		WindowPosition.CUSTOM:
			position = custom_position
		_:
			# Default to top right
			position = Vector2(viewport_size.x - size.x - margin.x, margin.y)

func create_ui_structure():
	# Main vertical container
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchor_and_offset(SIDE_LEFT, 0, 5)
	main_vbox.set_anchor_and_offset(SIDE_TOP, 0, 5)
	main_vbox.set_anchor_and_offset(SIDE_RIGHT, 1, -5)
	main_vbox.set_anchor_and_offset(SIDE_BOTTOM, 1, -5)
	add_child(main_vbox)
	
	# Title bar
	create_title_bar(main_vbox)
	
	# Scrollable content
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size.y = 200
	main_vbox.add_child(scroll)
	
	content_container = VBoxContainer.new()
	content_container.add_theme_constant_override("separation", 10)
	scroll.add_child(content_container)
	
	# Create sections
	if show_vectors_section:
		create_vector_section()
	if show_performance_section:
		create_performance_section()
	if show_components_section:
		create_component_section()
	if show_special_section:
		create_special_section()
	
	# Resize handle
	if resizable:
		create_resize_handle()

func create_title_bar(parent: VBoxContainer):
	title_bar = Panel.new()
	title_bar.custom_minimum_size.y = 30
	title_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var title_style = StyleBoxFlat.new()
	title_style.bg_color = header_color
	title_bar.add_theme_stylebox_override("panel", title_style)
	
	parent.add_child(title_bar)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchor_and_offset(SIDE_LEFT, 0, 5)
	hbox.set_anchor_and_offset(SIDE_TOP, 0, 0)
	hbox.set_anchor_and_offset(SIDE_RIGHT, 1, -5)
	hbox.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	title_bar.add_child(hbox)
	
	# Title
	title_label = Label.new()
	title_label.text = window_title
	title_label.add_theme_color_override("font_color", text_color)
	title_label.add_theme_font_size_override("font_size", 16)
	hbox.add_child(title_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	
	# Close button
	close_button = Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(25, 25)
	close_button.pressed.connect(_on_close_pressed)
	hbox.add_child(close_button)

func create_vector_section():
	vector_section = create_section("Vectors")
	
	# This section will be updated dynamically
	var vector_info = VBoxContainer.new()
	vector_section.add_child(vector_info)

func create_performance_section():
	performance_section = create_section("Performance")
	
	speed_label = create_info_label("Speed", "0 km/h")
	performance_section.add_child(speed_label)

	steer_label = create_info_label("Steer", "0,0")
	performance_section.add_child(steer_label)

	gravity_label = create_info_label("Gravity", "50")
	performance_section.add_child(gravity_label)
	
	weight_label = create_info_label("Total Weight", "0 kg")
	performance_section.add_child(weight_label)

func create_component_section():
	component_section = create_section("Components")
	
	fuel_label = create_info_label("Fuel", "0%")
	component_section.add_child(fuel_label)
	
	passenger_label = create_info_label("Passengers", "0/0")
	component_section.add_child(passenger_label)
	
	tire_label = create_info_label("Tire Wear", "100%")
	component_section.add_child(tire_label)
	
	engine_label = create_info_label("Engine Temp", "20°C")
	component_section.add_child(engine_label)

func create_special_section():
	special_section = create_section("Special")
	# Content will be added based on power source

func create_section(title: String) -> VBoxContainer:
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 5)
	
	# Section header
	var header = Label.new()
	header.text = "▼ " + title
	header.add_theme_color_override("font_color", value_color)
	header.add_theme_font_size_override("font_size", 14)
	section.add_child(header)
	
	# Separator
	var separator = HSeparator.new()
	section.add_child(separator)
	
	content_container.add_child(section)
	return section

func create_info_label(key: String, value: String) -> HBoxContainer:
	var container = HBoxContainer.new()
	
	var key_label = Label.new()
	key_label.text = key + ":"
	key_label.custom_minimum_size.x = 120
	key_label.add_theme_color_override("font_color", text_color)
	container.add_child(key_label)
	
	var value_label = Label.new()
	value_label.text = value
	value_label.add_theme_color_override("font_color", value_color)
	container.add_child(value_label)
	
	return container

func create_resize_handle():
	resize_handle = TextureRect.new()
	resize_handle.custom_minimum_size = Vector2(20, 20)
	resize_handle.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	resize_handle.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	resize_handle.set_anchor_and_offset(SIDE_LEFT, 1, -20)
	resize_handle.set_anchor_and_offset(SIDE_TOP, 1, -20)
	resize_handle.set_anchor_and_offset(SIDE_RIGHT, 1, 0)
	resize_handle.set_anchor_and_offset(SIDE_BOTTOM, 1, 0)
	add_child(resize_handle)

func find_bus():
	# Try to find bus in parent hierarchy
	var parent = get_parent()
	while parent:
		if parent is GameVehicle:
			bus = parent
			break
		parent = parent.get_parent()
	
	# If not found, search the scene
	if not bus:
		var buses = get_tree().get_nodes_in_group("buses")
		if buses.size() > 0 and buses[0] is GameVehicle:
			bus = buses[0]

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if clicking on title bar
				var local_pos = event.position
				if title_bar and title_bar.get_rect().has_point(local_pos) and draggable:
					is_dragging = true
					drag_offset = local_pos
					# When user starts dragging, switch to custom position mode
					default_position = WindowPosition.CUSTOM
				elif resize_handle and resize_handle.get_rect().has_point(local_pos) and resizable:
					is_resizing = true
					drag_offset = event.position
			else:
				is_dragging = false
				is_resizing = false
	
	elif event is InputEventMouseMotion:
		if is_dragging:
			position = event.global_position - drag_offset
			# Keep window within screen bounds
			var viewport_size = get_viewport().get_visible_rect().size
			position.x = clamp(position.x, 0, viewport_size.x - size.x)
			position.y = clamp(position.y, 0, viewport_size.y - size.y)
		elif is_resizing:
			var new_size = event.position
			custom_minimum_size = new_size.clamp(Vector2(200, 150), Vector2(800, 600))
			size = custom_minimum_size
			
			# If anchored to right side, adjust position to keep it at the edge
			if default_position in ["top_right", "bottom_right"]:
				var viewport_size = get_viewport().get_visible_rect().size
				position.x = viewport_size.x - size.x - margin.x

func _process(delta):
	if not bus:
		find_bus()
		return
	
	# Update content at specified rate
	update_timer += delta
	if update_timer >= update_rate:
		update_timer = 0.0
		update_content()

func update_content():
	if not bus:
		return
	
	# Update performance section
	if speed_label:
		var speed_kmh = int(bus.current_speed * 3.6)
		var speed_color = value_color
		if speed_kmh > 80:
			speed_color = warning_color
		elif speed_kmh > 120:
			speed_color = critical_color
		update_label_value(speed_label, "%d km/h" % speed_kmh, speed_color)
	if steer_label:
		var move_value = int(bus.movement_angle * 100)
		var steer_value = int(bus.visual_rotation * 100)
		var steer_color = value_color
		update_label_value(steer_label, "%d,%d" % [move_value, steer_value], steer_color)

	if gravity_label and bus.check_road_properties:
		var gravity_color = value_color
		var gravity_text = str(bus.current_gravity)
		if bus.current_gravity < 40:
			gravity_color = Color.GREEN
			gravity_text += " ↓"
		elif bus.current_gravity > 60:
			gravity_color = critical_color
			gravity_text += " ↑"
		update_label_value(gravity_label, gravity_text, gravity_color)
	
	if weight_label:
		update_label_value(weight_label, "%d kg" % int(bus.total_weight))
	
	# Update component section
	if fuel_label and bus.power_source:
		var fuel_percent = int((bus.power_source.current_fuel / bus.power_source.fuel_capacity) * 100)
		var fuel_color = value_color
		if fuel_percent < 20:
			fuel_color = critical_color
		elif fuel_percent < 50:
			fuel_color = warning_color
		update_label_value(fuel_label, "%d%%" % fuel_percent, fuel_color)
	
	if passenger_label and bus.passenger_section:
		var current = bus.passenger_section.current_passengers
		var capacity = bus.passenger_section.get_total_capacity()
		var ratio = float(current) / float(capacity) if capacity > 0 else 0.0
		var color = value_color
		if ratio > 0.9:
			color = critical_color
		elif ratio > 0.7:
			color = warning_color
		update_label_value(passenger_label, "%d/%d" % [current, capacity], color)
	
	if tire_label and bus.tires:
		var wear = int(bus.tires.wear_level)
		var color = value_color
		if wear < 30:
			color = critical_color
		elif wear < 60:
			color = warning_color
		update_label_value(tire_label, "%d%%" % wear, color)
	
	if engine_label and bus.engine:
		var temp = int(bus.engine.temperature)
		var color = value_color
		if temp > 100:
			color = critical_color
		elif temp > 80:
			color = warning_color
		update_label_value(engine_label, "%d°C" % temp, color)
	
	# Update special section based on power source
	update_special_section()

func update_label_value(label_container: HBoxContainer, value: String, color: Color = value_color):
	if label_container.get_child_count() >= 2:
		var value_label = label_container.get_child(1)
		value_label.text = value
		value_label.add_theme_color_override("font_color", color)

func update_special_section():
	if not special_section or not bus or not bus.power_source:
		return
	
	# Clear existing content
	for child in special_section.get_children():
		if child is HSeparator or (child is Label and child.text.begins_with("▼")):
			continue
		child.queue_free()
	
	# Add power source specific info
	match bus.power_source.source_type:
		PowerSource.SourceType.PSYCHIC:
			var resonance = create_info_label("Resonance", 
				"%d%%" % int(bus.power_source.psychic_resonance * 100))
			special_section.add_child(resonance)
			
		PowerSource.SourceType.ALIEN:
			var core = create_info_label("Core Health", 
				"%d%%" % int(bus.power_source.alien_core_health))
			special_section.add_child(core)
			
		PowerSource.SourceType.CHAOS:
			var stability = create_info_label("Stability", 
				"%d%%" % int(bus.power_source.chaos_stability * 100))
			special_section.add_child(stability)

func _on_close_pressed():
	hide()

func _on_viewport_size_changed():
	# Reposition window if it's anchored to a corner
	if default_position != WindowPosition.CUSTOM and not is_dragging:
		set_window_position(default_position)

# Public methods
func set_bus(new_bus: GameVehicle):
	bus = new_bus

func snap_to_corner(corner: WindowPosition):
	default_position = corner
	set_window_position(corner)

func reset_position():
	set_window_position(default_position)

func toggle_section(section_name: String):
	match section_name:
		"vectors":
			if vector_section:
				vector_section.visible = !vector_section.visible
		"performance":
			if performance_section:
				performance_section.visible = !performance_section.visible
		"components":
			if component_section:
				component_section.visible = !component_section.visible
		"special":
			if special_section:
				special_section.visible = !special_section.visible
