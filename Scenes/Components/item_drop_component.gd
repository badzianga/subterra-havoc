# Component used by enemies to set potential drops and their chances.
# To use, simply add it to enemy, set HealthComponent in export variable and fill drops array.
# After death, enemy will drop items depending on chances.

class_name ItemDropComponent
extends Node2D

const ItemDropScene := preload("res://Scenes/Inventory/item_drop.tscn")

@export var _health_component: HealthComponent
@export var _drops: Array[ItemDropInfo] = []

 
func _ready() -> void:
	_health_component.health_depleted.connect(_on_health_depleted)


# Iterates over drops array and checks, if can spawn item. If so, initializes item's id and texture
# and adds it to the world near the enemy's death coordinates.
func _on_health_depleted() -> void:
	for drop_info: ItemDropInfo in _drops:
		if randf() <= drop_info.drop_chance:
			var _item_drop := ItemDropScene.instantiate()
			_item_drop.initialize_item(drop_info.drop_id)
			_item_drop.global_position = global_position
			_item_drop.global_position.x += randf_range(-8.0, 8.0)
			GlobalVariables.map_node.call_deferred("add_child", _item_drop)
