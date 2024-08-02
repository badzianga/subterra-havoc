extends Node

const INVENTORY_SAVE_FILE_PATH := "user://inventory.save"


func save_game() -> void:
	_save_inventory_data()


func load_game() -> void:
	_load_inventory_data()


func _save_inventory_data() -> void:
	var save_dict := {
		"Inventory": PlayerInventory.inventory,
		"Hotbar": PlayerInventory.hotbar,
		"Equips": PlayerInventory.equips,
	}
	
	var save_file := FileAccess.open(INVENTORY_SAVE_FILE_PATH, FileAccess.WRITE)
	var json_string := JSON.stringify(save_dict)
	save_file.store_line(json_string)
	save_file.close()
	print("Saved inventory!")


func _load_inventory_data() -> void:
	assert(FileAccess.file_exists(INVENTORY_SAVE_FILE_PATH))
	var save_file := FileAccess.open(INVENTORY_SAVE_FILE_PATH, FileAccess.READ)
	var json_string := save_file.get_line()
	save_file.close()
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	assert(parse_result == OK)
	var save_dict: Dictionary = json.get_data()
	PlayerInventory.inventory = save_dict["Inventory"]
	PlayerInventory.hotbar = save_dict["Hotbar"]
	PlayerInventory.equips = save_dict["Equips"]
	print("Loaded inventory!")
