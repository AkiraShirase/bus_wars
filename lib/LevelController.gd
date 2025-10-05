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
