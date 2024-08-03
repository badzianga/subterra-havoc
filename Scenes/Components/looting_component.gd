# Simple component to keep track of items (of class ItemDrop) in area near the
# player.
#
# To use, simply add a CollisionShape to it.
# items_in_range is a public variable, so it is possible to remove items from
# array manually.
#
# Note that it might be a temporary solution or temporary implementation.

class_name LootingComponent
extends Area2D

var items_in_range: Array[ItemDrop]


func _on_body_entered(body: ItemDrop) -> void:
	items_in_range.append(body)


func _on_body_exited(body: ItemDrop) -> void:
	items_in_range.erase(body)
