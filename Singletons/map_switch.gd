# Singleton used for switching maps. Should be called mostly by portal script.

extends Node


# IMPORTANT! this function must be called deferred! Map change should occur only
# during frame's end.
func change_map(map_path: String) -> void:
	var _next_map_scene := load(map_path) as PackedScene
	
	# just to make sure I won't accidentally use old nodes, I'm deleting all references to them
	# so potential usage will result in critical error (using null value)
	GlobalVariables.clear_all()
	
	var error := get_tree().change_scene_to_packed(_next_map_scene)
	if error != OK:
		print("Couldn't change map to: ", map_path)
