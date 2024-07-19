# FIXME: switching weapons in the same slot doesn't update weapon node

class_name WeaponController
extends Node2D

@export var _weapon_marker: Marker2D

var _weapon: Sprite2D


func _ready() -> void:
	PlayerInventory.active_item_updated.connect(_on_active_item_updated)
	_on_active_item_updated()


func handle_weapon() -> void:
	if _weapon == null:
		return
	var _attack_direction := _weapon_marker.global_position.direction_to(
			get_global_mouse_position())
	# TODO: don't add PI here when Max start drawing sprites facing right
	var _angle := PI + _attack_direction.angle()
	_weapon_marker.rotation = _angle
	if Input.is_action_just_pressed("attack") and _weapon.can_attack():
		_weapon.attack(_attack_direction)


# TODO: now type from json is used. In the future, maybe change it to slot type.
func _on_active_item_updated() -> void:
	# FIXME: checking this right here is VERY bad, because spamming the same hotbar slot number
	# is calling this function, thus deleting and creating the same weapon.
	# With this, no cooldown is possible
	if _weapon != null:
		_weapon.queue_free()
	if PlayerInventory.hotbar.get(PlayerInventory.active_item_slot) == null:
		return
	var _item_id: String = PlayerInventory.hotbar[PlayerInventory.active_item_slot][0]
	var _item_category: String = ItemData.item_data[_item_id]["Category"]
	if _item_category != "Melee" and _item_category != "Ranged":
		return
	# TODO: create weapon based on templates and properties instead of loading pre-defined scenes
	var _weapon_scene := load("res://Scenes/Weapons/" + ItemData.item_data[_item_id]["Node"]) as PackedScene
	_weapon = _weapon_scene.instantiate()
	add_child(_weapon)
