extends Node

# TODO: load this number from Inventory scene OR create these amount of slots in Inventory scene 
const NUM_INVENTORY_SLOTS := 20

var inventory := {
	0: ["Iron Sword", 1]  # slot_index: [item_name, item_quantity]
}

var hotbar := {
	0: ["Iron Sword", 1],
	1: ["Tree Branch", 69]
}



func add_item(item_name: String, item_quantity: int) -> void:
	for i: int in inventory.size():
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
	inventory[slot.index] = [item.item_name, item.item_quantity]


func remove_item(slot: Slot) -> void:
	inventory.erase(slot.index)


func add_item_quantity(slot: Slot, quantity: int) -> void:
	inventory[slot.index][1] += quantity


func _update_slot_visual(slot_index: int, item_name: String, item_quantity: int) -> void:
	# TODO: this method might not be necessary (if opening inventory will cause pause)
	# also, Inventory stored in variable in singleton might be a better idea
	var slot: Slot = GlobalVariables.player.inventory.inventory_slots.get_child(slot_index)
	if slot.item != null:
		slot.item.set_item(item_name, item_quantity)
	else:
		slot.initialize_item(item_name, item_quantity)
