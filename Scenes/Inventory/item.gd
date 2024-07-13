# Iventory item class, which handles its data about ID and quantity in stack.

class_name Item
extends Control

var id: String
var quantity: int

@onready var _quantity_label := $Quantity
@onready var _texture_rect := $Texture


# Initializes inventory item node's children - sets texture and quantity label.
func set_item(item_id: String, item_quantity: int) -> void:
	id = item_id
	quantity = item_quantity
	
	var _item_file_name := ItemData.item_data[id]["FileName"] as String
	_texture_rect.texture = load(&"res://Assets/Items/" + _item_file_name)
	var _stack_size := int(ItemData.item_data[id]["StackSize"])
	
	if _stack_size == 1:
		_quantity_label.visible = false
	else:
		_quantity_label.text = str(item_quantity)


# Increases amount of stored items in stack and updates quantity label.
func increase_item_quantity(amount_to_add: int) -> void:
	quantity += amount_to_add
	_quantity_label.text = str(quantity)


# Decreases amount of stored items in stack and updates quantity label.
func decrease_item_quantity(amount_to_remove: int) -> void:
	quantity -= amount_to_remove
	_quantity_label.text = str(quantity)
