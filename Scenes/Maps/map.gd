class_name Map
extends Node2D

enum MapType {
	VILLAGE = 0,
	CAVES,
	CAMP,
}

@export var _map_type: MapType  # currently unused


func _ready() -> void:
	GlobalVariables.map_node = self
