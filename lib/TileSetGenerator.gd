@tool
extends Node
class_name TileSetGenerator

@export_group("Generator Controls")
@export var generate_tileset: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			_generate_and_assign_tileset()
		generate_tileset = false

func _generate_and_assign_tileset() -> void:
	var parent = get_parent()
	if not parent is TileMapLayer:
		push_error("TileSetGenerator must be a child of TileMapLayer")
		return

	var tile_map_layer = parent as TileMapLayer

	# Create new TileSet
	var tile_set = TileSet.new()
	tile_set.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tile_set.tile_size = Vector2i(64, 32)

	# Generate shader-based texture
	var shader_texture = _generate_isometric_texture()

	# Create TileSetAtlasSource
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = shader_texture
	atlas_source.texture_region_size = Vector2i(64, 32)

	# Add a tile to the atlas
	atlas_source.create_tile(Vector2i(0, 0))

	# Add atlas source to tileset
	tile_set.add_source(atlas_source, 0)

	# Assign tileset to tilemap
	tile_map_layer.tile_set = tile_set

	# Mark as changed for editor
	tile_map_layer.notify_property_list_changed()

	print("TileSet generated and assigned successfully")

func _generate_isometric_texture() -> ImageTexture:
	# Load the shader
	var shader = load("res://shaders/isometric_tile.gdshader")
	if not shader:
		push_error("Failed to load shader at res://shaders/isometric_tile.gdshader")
		return null

	# Create an Image directly
	var image = Image.create(64, 32, false, Image.FORMAT_RGBA8)

	# Fill the image with a simple isometric tile pattern
	# Since we can't easily execute shaders in the editor, we'll create the pattern manually
	for y in range(32):
		for x in range(64):
			var color = _calculate_isometric_pixel(x, y)
			image.set_pixel(x, y, color)

	# Create ImageTexture
	var texture = ImageTexture.create_from_image(image)

	return texture

func _calculate_isometric_pixel(x: int, y: int) -> Color:
	# Normalize coordinates to 0-1 range
	var uv_x = float(x) / 64.0
	var uv_y = float(y) / 32.0

	# Center coordinates
	var center_x = (uv_x - 0.5) * 2.0
	var center_y = (uv_y - 0.5) * 2.0

	# Calculate distance for isometric diamond shape
	# For 2:1 ratio isometric tile
	var dist_x = abs(center_x) * 32.0
	var dist_y = abs(center_y) * 64.0
	var dist = dist_x + dist_y

	# Define colors
	var base_color = Color(0.3, 0.6, 0.3, 1.0)
	var edge_color = Color(0.2, 0.4, 0.2, 1.0)

	# Edge detection
	var edge_threshold = 64.0 * 0.9

	# Diamond shape boundary
	if dist > 64.0:
		return Color(0, 0, 0, 0)  # Transparent outside diamond
	elif dist > edge_threshold:
		return edge_color
	else:
		return base_color
