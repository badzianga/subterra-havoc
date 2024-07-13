# Slot class used for all inventories.

class_name Slot
extends Panel

signal input_received(event: InputEvent, slot: Slot)

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	MELEE,
	RANGED,
	SHIRT,
	PANTS,
	SHOES,
}

const DefaultTexture := preload("res://Assets/UI/item_slot_default_background.png")
const EmptyTexture := preload("res://Assets/UI/item_slot_empty_background.png")
const SelectedTexture := preload("res://Assets/UI/item_slot_selected_background.png")
const ItemClass := preload("res://Scenes/Inventory/item.tscn")

@export var _offset_in_slot := Vector2(4.0, 4.0)

var item: Item  # item stored in slot
var index: int  # initialized in inventories' scripts
var slot_type: SlotType


# Creates item of passed ID and quantity in current slot and updates slot's style.
func initialize_item(item_id: String, item_quantity: int) -> void:
	if item == null:
		item = ItemClass.instantiate()  # TODO: check if Item.new() is possible
		item.position = _offset_in_slot
		add_child(item)
	item.set_item(item_id, item_quantity)
	_refresh_style()


# "Picks" item from current slot - adding item to UserInterface and changing slot's style.
func pick_item_from_slot() -> void:
	remove_child(item)
	GlobalVariables.user_interface_node.add_child(item)
	item = null
	_refresh_style()


# "Puts" item to the current slot - adding it to the slot, removing it from UserInterface and
# changing slot's style.
func put_item_into_slot(new_item: Item) -> void:
	item = new_item
	item.position = Vector2(4.0, 4.0)
	GlobalVariables.user_interface_node.remove_child(item)
	add_child(item)
	_refresh_style()


# Sets panel style depending of the slot content and current active slot (if hotbar).
func _refresh_style() -> void:
	var style := StyleBoxTexture.new()
	if slot_type == SlotType.HOTBAR and index == PlayerInventory.active_item_slot:
		style.texture = SelectedTexture
	elif item:
		style.texture = DefaultTexture
	else:
		style.texture = EmptyTexture
	set("theme_override_styles/panel", style)


# Emits signal containing provided input event to slot and the slot itself, so inventory knows which
# slot got input signal.
func _on_gui_input(event: InputEvent) -> void:
	input_received.emit(event, self)
