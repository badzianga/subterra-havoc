# Singleton used for saving and loading data to/from save files.

extends Node

const RUN_STATE_SAVE_FILE_PATH := "user://run_state.save"


# I can't think on anything better, so I'm loading scene-related data to buffer
# dictionary. When scenes are created, they check if this dictionary is empty.
# If not, then it loads specific variables and deletes them. When game starts,
# this dictionary should be empty - proper assertion can be made in map scene.
var loaded_data := {}
var just_loaded := false


func save_game() -> void:
	_save_run_state_data()


func load_game() -> void:
	_load_run_state_data()
	just_loaded = true


func _save_run_state_data() -> void:
	var save_dict := {
		"Inventory": PlayerInventory.inventory,
		"Hotbar": PlayerInventory.hotbar,
		"Equips": PlayerInventory.equips,
		"PlayerHealth": GlobalVariables.player.health_component.health,
		"PlayerMaxHealth": GlobalVariables.player.health_component.max_health,
		"CurrentMapPath": GlobalVariables.map_node.get_scene_file_path(),
	}
	
	var save_file := FileAccess.open(RUN_STATE_SAVE_FILE_PATH, FileAccess.WRITE)
	var json_string := JSON.stringify(save_dict)
	save_file.store_line(json_string)
	save_file.close()
	print("Game saved!")


func _load_run_state_data() -> void:
	if not FileAccess.file_exists(RUN_STATE_SAVE_FILE_PATH):
		print("Save file doesn't exist - skipping loading...")
		return
	var save_file := FileAccess.open(RUN_STATE_SAVE_FILE_PATH, FileAccess.READ)
	var json_string := save_file.get_line()
	save_file.close()
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	assert(parse_result == OK)
	var save_dict: Dictionary = json.get_data()
	# TOOD: temporary cleaning
	PlayerInventory.inventory.clear()
	PlayerInventory.hotbar.clear()
	PlayerInventory.equips.clear()
	# So, because json stores int keys as strings and I'm too lazy to look for
	# all occurences of slot id as int, I did this terribleness, so old code
	# will still work and performance shouldn't drop 
	for key in save_dict["Inventory"]:
		PlayerInventory.inventory[int(key)] = save_dict["Inventory"][key]
	for key: String in save_dict["Hotbar"]:
		PlayerInventory.hotbar[int(key)] = save_dict["Hotbar"][key]
	for key: String in save_dict["Equips"]:
		PlayerInventory.equips[int(key)] = save_dict["Equips"][key]
	
	loaded_data["PlayerHealth"] = save_dict["PlayerHealth"]
	loaded_data["PlayerMaxHealth"] = save_dict["PlayerMaxHealth"]
	loaded_data["CurrentMapPath"] = save_dict["CurrentMapPath"]
	print("Game loaded!")
