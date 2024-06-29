class_name Inventory
extends Control

const SlotScene := preload("res://Scenes/Inventory/slot.tscn")

@onready var inventory_slots := $Background/Slots
@onready var equip_slots := $Background/EquipSlots

func _ready() -> void:
	var slots := inventory_slots.get_children()
	for i: int in range(slots.size()):
		slots[i].input_recieved.connect(_on_slot_input_recieved)
		slots[i].index = i
		slots[i].slot_type = Slot.SlotType.INVENTORY
		# TODO/FIXME: I don't know whether it is necessary here or not, but I will leave it here for now
		slots[i]._refresh_style()
	
	var e_slots := equip_slots.get_children()
	for i: int in range(e_slots.size()):
		e_slots[i].input_recieved.connect(_on_slot_input_recieved)
		e_slots[i].index = i
		e_slots[i].slot_type = (Slot.SlotType.SHIRT + i)
	
	initialize_inventory()
	initialize_equips()


func _input(_event: InputEvent) -> void:
	if PlayerInventory.holding_item:
		PlayerInventory.holding_item.global_position = get_global_mouse_position()


func initialize_inventory() -> void:
	var slots := inventory_slots.get_children()
	for i: int in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])


func initialize_equips() -> void:
	var slots := equip_slots.get_children()
	for i: int in range(slots.size()):
		if PlayerInventory.equips.has(i):
			slots[i].initialize_item(PlayerInventory.equips[i][0], PlayerInventory.equips[i][1])


func _left_click_empty_slot(slot: Slot) -> void:
	if not _able_to_put_into_slot(slot):
		return
	# TODO: why holding_item? I think this function should be called AFTER put_into_slot
	PlayerInventory.add_item_to_empty_slot(PlayerInventory.holding_item, slot)
	slot.put_into_slot(PlayerInventory.holding_item)
	PlayerInventory.holding_item = null


func _left_click_different_item(event: InputEvent, slot: Slot) -> void:
	if not _able_to_put_into_slot(slot):
		return
	PlayerInventory.remove_item(slot)
	PlayerInventory.add_item_to_empty_slot(PlayerInventory.holding_item, slot)
	var temp_item := slot.item
	slot.pick_from_slot()
	temp_item.global_position = event.global_position
	slot.put_into_slot(PlayerInventory.holding_item)
	PlayerInventory.holding_item = temp_item


func _left_click_same_item(slot: Slot) -> void:
	if not _able_to_put_into_slot(slot):
		return
	var _stack_size := int(ItemData.item_data[slot.item.item_name]["StackSize"])
	var _able_to_add := _stack_size - slot.item.item_quantity
	if _able_to_add >= PlayerInventory.holding_item.item_quantity:
		PlayerInventory.add_item_quantity(slot, PlayerInventory.holding_item.item_quantity)
		slot.item.increase_item_quantity(PlayerInventory.holding_item.item_quantity)
		PlayerInventory.holding_item.queue_free()
		PlayerInventory.holding_item = null
	else:
		PlayerInventory.add_item_quantity(slot, _able_to_add)
		slot.item.increase_item_quantity(_able_to_add)
		PlayerInventory.holding_item.decrease_item_quantity(_able_to_add)


func _left_click_no_holding(slot: Slot) -> void:
	PlayerInventory.remove_item(slot)
	PlayerInventory.holding_item = slot.item
	slot.pick_from_slot()
	PlayerInventory.holding_item.global_position = get_global_mouse_position()


func _able_to_put_into_slot(slot: Slot) -> bool:
	if PlayerInventory.holding_item == null:
		return true
	var _holding_item_category: String = ItemData.item_data[PlayerInventory.holding_item.item_name]["ItemCategory"]
	if slot.slot_type == Slot.SlotType.SHIRT:
		return _holding_item_category == "Shirt"
	if slot.slot_type == Slot.SlotType.PANTS:
		return _holding_item_category == "Pants"
	if slot.slot_type == Slot.SlotType.SHOES:
		return _holding_item_category == "Shoes"
	return true


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
