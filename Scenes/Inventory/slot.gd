class_name Slot
extends Panel

const DefaultTexture := preload("res://Assets/Inventory/item_slot_default_background.png")
const EmptyTexture := preload("res://Assets/Inventory/item_slot_empty_background.png")
const ItemClass := preload("res://Scenes/Inventory/item.tscn")

signal input_recieved(event: InputEvent, slot: Slot)

var default_style: StyleBoxTexture
var empty_style: StyleBoxTexture
var item: Item
var index: int


func _ready() -> void:
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	
	default_style.texture = DefaultTexture
	empty_style.texture = EmptyTexture
	
	_refresh_style()


func pick_from_slot() -> void:
	remove_child(item)
	var inventory_node: Inventory = find_parent("Inventory")
	inventory_node.add_child(item)
	item = null
	_refresh_style()


func put_into_slot(new_item: Item) -> void:
	item = new_item
	item.position = Vector2.ONE
	var inventory_node: Inventory = find_parent("Inventory")
	inventory_node.remove_child(item)
	add_child(item)
	_refresh_style()


func initialize_item(item_name: String, item_quantity: int) -> void:
	if item == null:
		item = ItemClass.instantiate()
		add_child(item)
	item.set_item(item_name, item_quantity)
	_refresh_style()


func _refresh_style() -> void:
	if item:
		set("theme_override_styles/panel", default_style)
	else:
		set("theme_override_styles/panel", empty_style)


func _on_gui_input(event: InputEvent) -> void:
	input_recieved.emit(event, self)
