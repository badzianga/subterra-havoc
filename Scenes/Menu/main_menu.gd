extends Control


func _ready() -> void:
	# I want to see how long loading all singletons and menu takes
	Logger.debug("Main menu loaded")


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_delete_save"):
		SaveSystem.delete_run_save()


func _on_start_button_pressed() -> void:
	SaveSystem.load_game()
	if not SaveSystem.loaded_data.is_empty():
		var path: String = SaveSystem.loaded_data["CurrentMapPath"]
		SaveSystem.loaded_data.erase("CurrentMapPath")
		MapSwitch.change_map(path)
	else:
		MapSwitch.change_map("res://Scenes/Maps/village.tscn")


func _on_settings_button_pressed() -> void:
	pass


func _on_exit_button_pressed() -> void:
	get_tree().quit()
