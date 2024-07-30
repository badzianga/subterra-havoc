# TODO: for optimization, it's possible to change process mode to When Paused instead of Always
# and here only disabling pause menu. However, pause menu should be then enabled in player script.

extends Panel

const VILLAGE_SCENE_PATH := "res://Scenes/Maps/village.tscn"


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = not get_tree().paused
		visible = not visible
	if visible:
		if GlobalVariables.map_node.map_type != GlobalVariables.map_node.MapType.CAMP:
			$Buttons/LobbyButton.disabled = true
		for node: Control in $Buttons.get_children():
			if node is Button and node.disabled:
				node.mouse_default_cursor_shape = Control.CURSOR_ARROW


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_lobby_button_pressed() -> void:
	get_tree().paused = false
	MapSwitch.change_map(VILLAGE_SCENE_PATH)


func _on_exit_button_pressed() -> void:
	# TODO: save current progress
	get_tree().quit()
