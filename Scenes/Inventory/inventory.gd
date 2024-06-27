class_name Inventory
extends Control

const SlotScene := preload("res://Scenes/Inventory/slot.tscn")

@onready var inventory_slots := $Background/Slots

var holding_item: Item


func _ready() -> void:
	for slot: Panel in inventory_slots.get_children():
		slot.input_recieved.connect(_on_slot_input_recieved)
	initialize_inventory()


func _input(_event: InputEvent) -> void:
	if holding_item:
		holding_item.global_position = get_global_mouse_position()


func initialize_inventory() -> void:
	var slots := inventory_slots.get_children()
	for i: int in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])


func _on_slot_input_recieved(event: InputEvent, slot: Slot) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	# holding an item
	if holding_item != null:
		# empty slot
		if not slot.item:
			slot.put_into_slot(holding_item)
			holding_item = null
		# slot already contains an item
		else:
			# different item, so swap
			if holding_item.item_name != slot.item.item_name:
				var temp_item := slot.item
				slot.pick_from_slot()
				temp_item.global_position = event.global_position
				slot.put_into_slot(holding_item)
				holding_item = temp_item
			# same item, so try to merge
			else:
				var _stack_size := int(ItemData.item_data[slot.item.item_name]["StackSize"])
				var _able_to_add := _stack_size - slot.item.item_quantity
				if _able_to_add >= holding_item.item_quantity:
					slot.item.increase_item_quantity(holding_item.item_quantity)
					holding_item.queue_free()
					holding_item = null
				else:
					slot.item.increase_item_quantity(_able_to_add)
					holding_item.decrease_item_quantity(_able_to_add)
	# not holding an item
	elif slot.item:
		holding_item = slot.item
		slot.pick_from_slot()
		holding_item.global_position = get_global_mouse_position()
