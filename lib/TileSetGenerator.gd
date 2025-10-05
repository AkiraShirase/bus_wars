@tool
extends Node
class_name TileSetGenerator

@export_group("Generator Controls")
@export var width: int = 64
@export var height: int = 64
@export var material: ShaderMaterial
@export var generate_tileset: bool = false:
	set(value):
		if value:
			_generate_and_assign_tileset()
		generate_tileset = false

func _generate_and_assign_tileset() -> void:
	var parent = get_parent()
	if not parent is TileMapLayer:
		push_error("TileSetGenerator must be a child of TileMapLayer")
		return

	var tile_map_layer = parent as TileMapLayer

	# Create new TileSet
	if tile_map_layer.tile_set == null:
		var _tile_set = TileSet.new() 
		_tile_set.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
		_tile_set.tile_size = Vector2i(width, height)
		tile_map_layer.tile_set = _tile_set

	# Generate shader-based texture
	var shader_texture = await bake_single_road_tile()

	# Create TileSetAtlasSource
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = shader_texture
	atlas_source.texture_region_size = Vector2i(width, height)

	# Add a tile to the atlas
	atlas_source.create_tile(Vector2i(0, 0))

	if tile_map_layer.tile_set.has_source(0):
		tile_map_layer.tile_set.remove_source(0)

	# Add atlas source to tileset
	tile_map_layer.tile_set.add_source(
		atlas_source, 
		tile_map_layer.tile_set.get_source_count(),
	)

	# Mark as changed for editor
	tile_map_layer.notify_property_list_changed()

	print("TileSet generated and assigned successfully")

func bake_single_road_tile() -> ImageTexture:
	var viewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.sdf_oversize = 1 # Add this line to fix dark edges
	viewport.size = Vector2i(width, height)
	add_child(viewport)
	
	var rect = ColorRect.new()
	rect.size = Vector2(width, height)

	rect.material = material
	
	viewport.add_child(rect)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	
	var image = viewport.get_texture().get_image()
	
	# This is the crucial step to fix the dark edges.
	# It "bleeds" the edge colors into the transparent area.
	image.generate_mipmaps()

	var texture = ImageTexture.create_from_image(image)
	
	viewport.queue_free()
	return texture
