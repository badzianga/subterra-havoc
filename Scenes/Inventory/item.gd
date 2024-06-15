class_name Item
extends Control


func _ready() -> void:
	if randi() % 2 == 0:
		$Texture.texture = load("res://Assets/Items/Iron Sword.png")
	else:
		$Texture.texture = load("res://Assets/Items/Tree Branch.png")
