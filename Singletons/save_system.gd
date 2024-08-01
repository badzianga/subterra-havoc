extends Node

const INVENTORY_SAVE_FILE_PATH := "user://inventory.json"


func save_game() -> void:
	_save_inventory_data()


func load_game() -> void:
	pass


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
