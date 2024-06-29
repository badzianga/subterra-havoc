class_name Slot
extends Panel

const DefaultTexture := preload("res://Assets/UI/item_slot_default_background.png")
const EmptyTexture := preload("res://Assets/UI/item_slot_empty_background.png")
const SelectedTexture := preload("res://Assets/UI/item_slot_selected_background.png")
const ItemClass := preload("res://Scenes/Inventory/item.tscn")

signal input_recieved(event: InputEvent, slot: Slot)

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	SHIRT,
	PANTS,
	SHOES,
}

var default_style: StyleBoxTexture
var empty_style: StyleBoxTexture
var selected_style: StyleBoxTexture
var item: Item
var index: int
var slot_type: SlotType


func _ready() -> void:
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	
	default_style.texture = DefaultTexture
	empty_style.texture = EmptyTexture
	selected_style.texture = SelectedTexture
	
	# FIXME: so, this line right here destroys indexing of slots, because first _ready is called
	# in slot, and then in hotbar/inventory
	# but because of commenting this line of code, inactive slots in hotbar are invisible (???)
	# for now, this call is moved into _ready of hotbar
	#_refresh_style()


func pick_from_slot() -> void:
	remove_child(item)
	var user_interface: CanvasLayer = find_parent("UserInterface")
	user_interface.add_child(item)
	item = null
	_refresh_style()


func put_into_slot(new_item: Item) -> void:
	item = new_item
	item.position = Vector2(4.0, 4.0)
	var user_interface: CanvasLayer = find_parent("UserInterface")
	user_interface.remove_child(item)
	add_child(item)
	_refresh_style()


func initialize_item(item_name: String, item_quantity: int) -> void:
	if item == null:
		item = ItemClass.instantiate()
		item.position = Vector2(4.0, 4.0)
		add_child(item)
	item.set_item(item_name, item_quantity)
	_refresh_style()


func _refresh_style() -> void:
	if slot_type == SlotType.HOTBAR and index == PlayerInventory.active_item_slot:
		set("theme_override_styles/panel", selected_style)
	elif item:
		set("theme_override_styles/panel", default_style)
	else:
		set("theme_override_styles/panel", empty_style)


func _on_gui_input(event: InputEvent) -> void:
	input_recieved.emit(event, self)
