extends Control

@onready var slots := $Background/Slots.get_children()


func _ready() -> void:
	for i: int in range(slots.size()):
		slots[i].connect_active_item_signal()  # TODO: maybe it can be called in _ready in slot.gd?
		slots[i].index = i
		slots[i].slot_type = Slot.SlotType.HOTBAR
		slots[i].input_recieved.connect(_on_slot_input_recieved)
		slots[i]._refresh_style()
	_initialize_inventory()


func _initialize_inventory() -> void:
	for i: int in range(slots.size()):
		# TODO: change hotbar to inventory later, and do some magic so the hotbar will be shortcut
		# to inventory instead of separate inventory
		if not PlayerInventory.hotbar.has(i):
			return
		slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])


# TODO: I'm basically copying and pasting the same code from Inventory, this methods should be
# somewhere else, so both scripts will use them
func _left_click_empty_slot(slot: Slot) -> void:
	# TODO: why holding_item? I think this function should be called AFTER put_into_slot
	PlayerInventory.add_item_to_empty_slot(PlayerInventory.holding_item, slot, true)
	slot.put_into_slot(PlayerInventory.holding_item)
	PlayerInventory.holding_item = null


func _left_click_different_item(event: InputEvent, slot: Slot) -> void:
	PlayerInventory.remove_item(slot, true)
	PlayerInventory.add_item_to_empty_slot(PlayerInventory.holding_item, slot, true)
	var temp_item := slot.item
	slot.pick_from_slot()
	temp_item.global_position = event.global_position
	slot.put_into_slot(PlayerInventory.holding_item)
	PlayerInventory.holding_item = temp_item


func _left_click_same_item(slot: Slot) -> void:
	var _stack_size := int(ItemData.item_data[slot.item.item_name]["StackSize"])
	var _able_to_add := _stack_size - slot.item.item_quantity
	if _able_to_add >= PlayerInventory.holding_item.item_quantity:
		PlayerInventory.add_item_quantity(slot, PlayerInventory.holding_item.item_quantity, true)
		slot.item.increase_item_quantity(PlayerInventory.holding_item.item_quantity)
		PlayerInventory.holding_item.queue_free()
		PlayerInventory.holding_item = null
	else:
		PlayerInventory.add_item_quantity(slot, _able_to_add, true)
		slot.item.increase_item_quantity(_able_to_add)
		PlayerInventory.holding_item.decrease_item_quantity(_able_to_add)


func _left_click_no_holding(slot: Slot) -> void:
	#PlayerInventory.remove_item(slot)
	PlayerInventory.holding_item = slot.item
	slot.pick_from_slot()
	PlayerInventory.holding_item.global_position = get_global_mouse_position()


func _on_slot_input_recieved(event: InputEvent, slot: Slot) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	# holding an item
	if PlayerInventory.holding_item != null:
		# empty slot
		if not slot.item:
			_left_click_empty_slot(slot)
		# slot already contains an item
		else:
			# different item, so swap
			if PlayerInventory.holding_item.item_name != slot.item.item_name:
				_left_click_different_item(event, slot)
			# same item, so try to merge
			else:
				_left_click_same_item(slot)
	# not holding an item
	elif slot.item:
		_left_click_no_holding(slot)
