class_name LootingComponent
extends Area2D

var items_in_range: Array[ItemDrop]


func _on_body_entered(body: ItemDrop) -> void:
	items_in_range.append(body)


func _on_body_exited(body: ItemDrop) -> void:
	items_in_range.erase(body)
