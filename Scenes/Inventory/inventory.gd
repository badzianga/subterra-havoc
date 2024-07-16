# Player's inventory class which handles all inventory inputs - e.g. moving, swapping items.
# TODO: maybe make equipment slots the same as normal slots?
# TODO: move all click functions to PlayerInventory singleton because they're also used by Hotbar
# OR completely change hotbar logic and usage.
# TODO: for sure move click functions to PlayerInventory singleton - chests will work the same.
# TODO: do something with using private function _refresh_style() from slot
# FIXME: leaving inventory while holding item makes it still visible on mouse, however moving it
# is not possible. With leaving inventory, tem should be put in first possible slot or original
#slot. If it is impossible, item should be put on ground as ItemDrop object with increased quantity. 

class_name Inventory
extends Control

const SlotScene := preload("res://Scenes/Inventory/slot.tscn")

@onready var inventory_slots := $Background/Slots
@onready var _equip_slots := $Background/EquipSlots


# Sets basic info about Inventory slots - indexes and slot_types. Also connects Slots' input signals
# with _on_slot_input_received(). After that, it calls initializers for slots, so they will have
# contained item and proper style.
func _ready() -> void:
	GlobalVariables.inventory_node = self
	# inventory slots
	var _slots := inventory_slots.get_children()
	for i: int in range(_slots.size()):
		_slots[i].input_received.connect(_on_slot_input_received)
		_slots[i].index = i
		_slots[i].slot_type = Slot.SlotType.INVENTORY
		# TODO: I don't know whether it is necessary here or not, but I will leave it here for now
		# UPDATE: it's not necessary, because initialize_inventory calls slots's initialize_item,
		# which calls its _refresh_style
		# UPDATE 2: it is indeed necessary, initialize_inventory initializes only slots with items
		_slots[i]._refresh_style()
	initialize_inventory()
	
	# equipment slots
	var _e_slots := _equip_slots.get_children()
	for i: int in range(_e_slots.size()):
		_e_slots[i].input_received.connect(_on_slot_input_received)
		_e_slots[i].index = i
		_e_slots[i].slot_type = (Slot.SlotType.SHIRT + i)
		_e_slots[i]._refresh_style()
	_initialize_equips()


# Updates held_item's global position with recieved input.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventMouseMotion:
		return
	if PlayerInventory.held_item != null:
		PlayerInventory.held_item.global_position = get_global_mouse_position()


# Initializes all inventory slots - calling intialize_item for every slot containing an item.
# With that all slots have proper style and set item.
# TODO: is it really necessary to update every slot?
# TODO: _ready() also iterates over all slots, is it possible to not iterate again?
func initialize_inventory() -> void:
	var _slots := inventory_slots.get_children()
	for i: int in range(_slots.size()):
		if PlayerInventory.inventory.has(i):
			_slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])


# Initializes all equipment slots - calling intialize_item for every equipment slot containing an
# item. With that all equipment slots have proper style and set item.
# It is a private function because equipment slots contains cannot be changed when collecting items,
# so it doesn't need to be called.
func _initialize_equips() -> void:
	var _slots := _equip_slots.get_children()
	for i: int in range(_slots.size()):
		if PlayerInventory.equips.has(i):
			_slots[i].initialize_item(PlayerInventory.equips[i][0], PlayerInventory.equips[i][1])


# Adds held item to the empty slot. If user tried to put item to invalid slot, ignores call.
func _left_click_empty_slot(slot: Slot) -> void:
	if not _able_to_put_into_slot(slot):
		return
	# TODO: why held_item? I think this function should be called AFTER put_item_into_slot
	PlayerInventory.add_item_to_empty_slot(PlayerInventory.held_item, slot)
	slot.put_item_into_slot(PlayerInventory.held_item)
	PlayerInventory.held_item = null


# Swaps held item with item in clicked slot.
func _left_click_different_item(event: InputEventMouseButton, slot: Slot) -> void:
	if not _able_to_put_into_slot(slot):
		return
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
	if not _able_to_put_into_slot(slot):
		return
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
	PlayerInventory.remove_item_from_slot(slot)
	PlayerInventory.held_item = slot.item
	slot.pick_item_from_slot()
	PlayerInventory.held_item.global_position = get_global_mouse_position()


# Checks if player can put item into slot - if he holds an item and if he's trying to put item
# into the slot of the correct category.
func _able_to_put_into_slot(slot: Slot) -> bool:
	if PlayerInventory.held_item == null:
		return true
	var _category: String = ItemData.item_data[PlayerInventory.held_item.id]["Category"]
	if slot.slot_type == Slot.SlotType.SHIRT:
		return _category == "Shirt"
	if slot.slot_type == Slot.SlotType.PANTS:
		return _category == "Pants"
	if slot.slot_type == Slot.SlotType.SHOES:
		return _category == "Shoes"
	return true


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
