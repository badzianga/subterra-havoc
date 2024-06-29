extends Node

signal active_item_updated

# TODO: load this number from Inventory scene OR create these amount of slots in Inventory scene 
const NUM_INVENTORY_SLOTS := 20
const NUM_HOTBAR_SLOTS := 5

var inventory := {
	0: ["Iron Sword", 1],  # slot_index: [item_name, item_quantity]
}

var hotbar := {
	0: ["Iron Sword", 1],
	1: ["Tree Branch", 69],
}

var equips := {
	0: ["Brown Shirt", 1],
	1: ["Blue Jeans", 1],
	2: ["Brown Boots", 1],
}

var active_item_slot := 0

# moved from inventory.gd, so it can be accessed from both inventory and hotbar
var holding_item: Item


func add_item(item_name: String, item_quantity: int) -> void:
	# HACK: before there was a loop in range of inventory size. Changed it to dictionary keys
	#for i: int in inventory.size():
	for i: int in inventory:
		if inventory[i][0] == item_name:
			var _stack_size := int(ItemData.item_data[item_name]["StackSize"])
			var _able_to_add: int = _stack_size - inventory[i][1]
			if _able_to_add >= item_quantity:
				inventory[i][1] += item_quantity
				_update_slot_visual(i, inventory[i][0], inventory[i][1])
				return
			else:
				inventory[i][1] += _able_to_add
				_update_slot_visual(i, inventory[i][0], inventory[i][1])
				item_quantity -= _able_to_add
				# because of the loop excess items will be added to next slot with the same item
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i: int in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			inventory[i] = [item_name, item_quantity]
			_update_slot_visual(i, inventory[i][0], inventory[i][1])
			return


# TODO: is item argument necessary? slot.item should be the same
# (only when this function is called after put_into_slot in inventory.gd) 
func add_item_to_empty_slot(item: Item, slot: Slot) -> void:
	match slot.slot_type:
		Slot.SlotType.HOTBAR:
			hotbar[slot.index] = [item.item_name, item.item_quantity]
		Slot.SlotType.INVENTORY:
			inventory[slot.index] = [item.item_name, item.item_quantity]
		_:
			equips[slot.index] = [item.item_name, item.item_quantity]


func remove_item(slot: Slot) -> void:
	match slot.slot_type:
		Slot.SlotType.HOTBAR:
			hotbar.erase(slot.index)
		Slot.SlotType.INVENTORY:
			inventory.erase(slot.index)
		_:
			equips.erase(slot.index)


func add_item_quantity(slot: Slot, quantity: int) -> void:
	match slot.slot_type:
		Slot.SlotType.HOTBAR:
			hotbar[slot.index][1] += quantity
		Slot.SlotType.INVENTORY:
			inventory[slot.index][1] += quantity
		_:
			equips[slot.index][1] += quantity


func active_item_scroll_up() -> void:
	active_item_slot = posmod(active_item_slot - 1, NUM_HOTBAR_SLOTS)
	active_item_updated.emit()


func active_item_scroll_down() -> void:
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	active_item_updated.emit()


func _update_slot_visual(slot_index: int, item_name: String, item_quantity: int) -> void:
	# TODO: this method might not be necessary (if opening inventory will cause pause)
	# also, Inventory stored in variable in singleton might be a better idea
	var slot: Slot = GlobalVariables.player.inventory.inventory_slots.get_child(slot_index)
	if slot.item != null:
		slot.item.set_item(item_name, item_quantity)
	else:
		slot.initialize_item(item_name, item_quantity)
