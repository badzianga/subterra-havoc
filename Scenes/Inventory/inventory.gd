class_name Inventory
extends Control

const SlotScene := preload("res://Scenes/Inventory/slot.tscn")

@onready var inventory_slots := $Slots

var holding_item: Item


func _ready() -> void:
	for slot: Panel in inventory_slots.get_children():
		slot.input_recieved.connect(_on_slot_input_recieved)


func _input(_event: InputEvent) -> void:
	if holding_item:
		holding_item.global_position = get_global_mouse_position()


func _on_slot_input_recieved(event: InputEvent, slot: Slot) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	if holding_item != null:
		if not slot.item:
			slot.put_into_slot(holding_item)
			holding_item = null
		else:
			var temp_item := slot.item
			slot.pick_from_slot()
			temp_item.global_position = event.global_position
			slot.put_into_slot(holding_item)
			holding_item = temp_item
	elif slot.item:
		holding_item = slot.item
		slot.pick_from_slot()
		holding_item.global_position = get_global_mouse_position()
