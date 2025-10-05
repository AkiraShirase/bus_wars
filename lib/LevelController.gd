extends Node
class_name LevelController

func init(level: BusLevel) -> void:
	# Check if map is already set
	if not level.map:
		# Create new TileMapLayer
		var tile_map_layer = TileMapLayer.new()
		tile_map_layer.name = "Map"
		level.add_child(tile_map_layer)
		level.map = tile_map_layer

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

func _generate_isometric_texture() -> Texture2D:
	# Load the shader
	var shader = load("res://shaders/isometric_tile.gdshader")

	# Create shader material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader

	# Create a SubViewport to render the shader
	var viewport = SubViewport.new()
	viewport.size = Vector2i(64, 32)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	# Create a ColorRect with the shader material
	var color_rect = ColorRect.new()
	color_rect.material = shader_material
	color_rect.size = Vector2(64, 32)

	# Add to viewport
	viewport.add_child(color_rect)

	# Add viewport temporarily to scene tree (required for rendering)
	add_child(viewport)

	# Wait for render
	await get_tree().process_frame
	await get_tree().process_frame

	# Get the texture
	var texture = viewport.get_texture()

	# Create an ImageTexture from the viewport texture
	var image = texture.get_image()
	var image_texture = ImageTexture.create_from_image(image)

	# Clean up
	viewport.queue_free()

	return image_texture
