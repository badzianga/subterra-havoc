extends Node

var item_data: Dictionary


func _ready() -> void:
	item_data = _load_data(&"res://Data/item_data.json")


func _load_data(file_path: StringName) -> Dictionary:
	var _file_data := FileAccess.get_file_as_string(file_path)
	var _json_data: Dictionary = JSON.parse_string(_file_data)
	return _json_data
