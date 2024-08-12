# Singleton used for switching maps. Should be called mostly by portal script.

extends Node

# TODO: maybe I can create village PackedScene variable. In (almost) every game it's going to be
# used anyway, so it can be loaded OR I can hold here path to village so it doesn't need to be hold
# in other scripts 


# IMPORTANT! this function must be called deferred! Map change should occur only
# during frame's end.
func change_map(map_path: String) -> void:
	var _next_map_scene := load(map_path) as PackedScene
	
	# just to make sure I won't accidentally use old nodes, I'm deleting all
	# references to them so potential usage will result in using null value
	GlobalVariables.clear_all()
	
	var error := get_tree().change_scene_to_packed(_next_map_scene)
	if error != OK:
		Logger.error("Couldn't change map to: %s (code: %d)" % [map_path, error])
