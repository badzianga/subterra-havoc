class_name Item
extends Control

var item_name: StringName
var item_quantity: int


func increase_item_quantity(amount_to_add: int) -> void:
	item_quantity += amount_to_add
	$Quantity.text = str(item_quantity)


func decrease_item_quantity(amount_to_remove: int) -> void:
	item_quantity -= amount_to_remove
	$Quantity.text = str(item_quantity)


func set_item(nm: String, qt: int) -> void:
	item_name = nm
	item_quantity = qt
	
	$Texture.texture = load(&"res://Assets/Items/" + item_name + &".png")
	var _stack_size := int(ItemData.item_data[item_name]["StackSize"])
	
	if _stack_size == 1:
		$Quantity.visible = false
	else:
		$Quantity.text = str(item_quantity)
