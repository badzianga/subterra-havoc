extends Area2D

const VILLAGE_SCENE_PATH := "res://Scenes/Maps/village.tscn"


func interact() -> void:
	Logger.debug("Interacted with sign - returning to lobby")
	MapSwitch.call_deferred("change_map", VILLAGE_SCENE_PATH)
	# TODO: spawn confirmation popup
