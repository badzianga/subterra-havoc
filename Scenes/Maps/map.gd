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
	
	# TODO: current problem is, loading save file will trigger saving again, which is redundant 
	if map_type == MapType.CAMP:
		SaveSystem.save_game()
	
	# TEMPORARY FOR DEBUG PURPOSES
	var _label: Label = $CanvasLayer/DebugLabel
	_label.text = "Name: " + name + ", type: " + MapType.keys()[map_type]
	await get_tree().create_timer(3.0).timeout
	var _tween := create_tween()
	_tween.tween_property(_label, "modulate", Color(255, 255, 255, 0), 1.0)
	_tween.tween_callback(_label.queue_free)
