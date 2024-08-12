# Map class used for all maps - village, camps and levels.

class_name Map
extends Node2D

enum MapType {
	VILLAGE = 0,
	CAVES,
	CAMP,
}

@export var map_type: MapType


func _ready() -> void:
	GlobalVariables.map_node = self
	
	if map_type == MapType.CAMP and not SaveSystem.just_loaded:
		SaveSystem.save_game()
	 
	if SaveSystem.just_loaded:
		SaveSystem.just_loaded = false
		assert(
			SaveSystem.loaded_data.is_empty(),
			"Something went wrong - buffered loaded data is not empty, 
			make sure to load everything"
		)
	
	Logger.info("Current map name: %s, type: %s" % [name, MapType.keys()[map_type]])
