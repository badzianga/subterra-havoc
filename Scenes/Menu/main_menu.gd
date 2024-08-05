extends Control


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
