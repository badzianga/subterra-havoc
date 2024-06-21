class_name Item
extends Control

var item_name: StringName
var item_quantity: int


func _ready() -> void:
	var _rand_val = randi() % 3
	if _rand_val == 0:
		item_name = &"Iron Sword"
	elif _rand_val == 1:
		item_name = &"Tree Branch"
	else:
		item_name = &"Slime Potion"
	
	$Texture.texture = load(&"res://Assets/Items/" + item_name + &".png")
	var _stack_size := int(ItemData.item_data[item_name]["StackSize"])
	item_quantity = randi() % _stack_size + 1
	
	if _stack_size == 1:
		$Quantity.visible = false
	else:
		$Quantity.text = str(item_quantity)


func increase_item_quantity(amount_to_add: int) -> void:
	item_quantity += amount_to_add
	$Quantity.text = str(item_quantity)


func decrease_item_quantity(amount_to_remove: int) -> void:
	item_quantity -= amount_to_remove
	$Quantity.text = str(item_quantity)
