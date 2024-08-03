# Portal class used for switching maps by creating areas which colliding with
# will trigger map change.

# FIXME: player body is not on World layer, so checking PlayerHurtbox
# however, dashing and damage temporarily disables hurtbox, so it will cause bugs later

class_name Portal
extends Area2D

@export_file("*.tscn") var _next_map_path: String


func _ready() -> void:
	assert(not _next_map_path.is_empty())


func _on_area_entered(_area: Area2D) -> void:
	MapSwitch.call_deferred("change_map", _next_map_path)
