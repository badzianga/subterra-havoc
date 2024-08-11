# Singleton for containing all item data in dictionary loaded from json file.

extends Node

const ITEM_DATA_FILE_PATH := &"res://Data/item_data.json"

var item_data: Dictionary


func _ready() -> void:
	item_data = _load_data(ITEM_DATA_FILE_PATH)
	Logger.debug("Loaded item data dictionary from file (%d items)" % item_data.size())


func _load_data(file_path: StringName) -> Dictionary:
	var _file_data := FileAccess.get_file_as_string(file_path)
	var _json_data: Dictionary = JSON.parse_string(_file_data)
	return _json_data
