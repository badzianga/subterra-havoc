# Player's hotbar which handles all inventory inputs - e.g. moving, swapping items.

extends Control

@onready var _slots := $Background/Slots.get_children()
@onready var _active_item_label := $Background/ActiveItemLabel


# Initializes all hotbar slots.
func _ready() -> void:
	PlayerInventory.active_item_updated.connect(_on_active_item_updated)
	for i: int in range(_slots.size()):
		PlayerInventory.active_item_updated.connect(_slots[i]._refresh_style)
		_slots[i].index = i
		_slots[i].slot_type = Slot.SlotType.HOTBAR
		_slots[i].input_received.connect(_on_slot_input_received)
		_slots[i]._refresh_style()
	_initialize_inventory()
	_update_active_item_label()


# Switches active hotbar slot with keys 1-5.
# TODO: it's called with every keyboard input event - event when moving.
# Is it possible to do something about it?
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("hotbar_slot_1"):
		PlayerInventory.active_item_slot = 0
		PlayerInventory.active_item_updated.emit()
	elif event.is_action_pressed("hotbar_slot_2"):
		PlayerInventory.active_item_slot = 1
		PlayerInventory.active_item_updated.emit()


# Initializes all inventory slots - calling intialize_item for every slot containing an item.
# With that all slots have proper style and set item.
# TODO: is it really necessary to update every slot?
# TODO: _ready() also iterates over all slots, is it possible to not iterate again?
func _initialize_inventory() -> void:
	for i: int in range(_slots.size()):
		# TODO: change hotbar to inventory later, and do some magic so the hotbar will be shortcut
		# to inventory instead of separate inventory
		if not PlayerInventory.hotbar.has(i):
			return
		_slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])


# Adds held item to the empty slot.
func _left_click_empty_slot(slot: Slot) -> void:
	# TODO: why held_item? I think this function should be called AFTER put_item_into_slot
	PlayerInventory.add_item_to_empty_slot(PlayerInventory.held_item, slot)
	slot.put_item_into_slot(PlayerInventory.held_item)
	PlayerInventory.held_item = null


# Swaps held item with item in clicked slot.
func _left_click_different_item(event: InputEventMouseButton, slot: Slot) -> void:
	# swap items in dictionary
	PlayerInventory.remove_item_from_slot(slot)
	PlayerInventory.add_item_to_empty_slot(PlayerInventory.held_item, slot)
	# swap items in slot and hand
	var _temp_item := slot.item
	slot.pick_item_from_slot()
	slot.put_item_into_slot(PlayerInventory.held_item)
	# set new held item's position and add it as current held item
	_temp_item.global_position = event.global_position
	PlayerInventory.held_item = _temp_item


# Adds the same held item to the clicked slot. If held item's quantity is bigger than slot's
# capacity, the slot is filled to the max, and difference is still held in hand.
func _left_click_same_item(slot: Slot) -> void:
	var _stack_size := int(ItemData.item_data[slot.item.id]["StackSize"])
	var _able_to_add := _stack_size - slot.item.quantity
	var _held_item_quantity := PlayerInventory.held_item.quantity
	# all held items can be added to slot
	if _able_to_add >= _held_item_quantity:
		PlayerInventory.increase_item_quantity(slot, _held_item_quantity)
		slot.item.increase_item_quantity(_held_item_quantity)
		PlayerInventory.held_item.queue_free()
		PlayerInventory.held_item = null
	# overflow - fill slot to the max and decrease held item's quantity
	else:
		PlayerInventory.increase_item_quantity(slot, _able_to_add)
		slot.item.increase_item_quantity(_able_to_add)
		PlayerInventory.held_item.decrease_item_quantity(_able_to_add)


# Takes item from clicked slot and puts it to the hand.
func _left_click_no_holding(slot: Slot) -> void:
	PlayerInventory.remove_item_from_slot(slot)  ## TODO: why was it commented?
	PlayerInventory.held_item = slot.item
	slot.pick_item_from_slot()
	PlayerInventory.held_item.global_position = get_global_mouse_position()


# Updates label so it will contain active item name.
func _update_active_item_label() -> void:
	var _active_item: Item = _slots[PlayerInventory.active_item_slot].item
	if _active_item != null:
		_active_item_label.text = ItemData.item_data[_active_item.id]["Name"]
	else:
		_active_item_label.text = ""


# Recieves input signal from the slots and decides, which action took place.
func _on_slot_input_received(event: InputEventMouseButton, slot: Slot) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	# holding an item
	if PlayerInventory.held_item != null:
		# empty slot
		if slot.item == null:
			_left_click_empty_slot(slot)
		# slot already contains an item
		else:
			# different item, so swap
			if PlayerInventory.held_item.id != slot.item.id:
				_left_click_different_item(event, slot)
			# same item, so try to merge
			else:
				_left_click_same_item(slot)
	# not holding an item
	elif slot.item != null:
		_left_click_no_holding(slot)
	_update_active_item_label()


# Callback to changing active item slot.
func _on_active_item_updated() -> void:
	_update_active_item_label()
