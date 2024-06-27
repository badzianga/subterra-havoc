extends Node

# TODO: load this number from Inventory scene OR create these amount of slots in Inventory scene 
const NUM_INVENTORY_SLOTS := 20

var inventory: Dictionary = {
	0: ["Iron Sword", 1]  # slot_index: [item_name, item_quantity]
}


func add_item(item_name: String, item_quantity: int) -> void:
	for i: int in inventory:
		if inventory[i][0] == item_name:
			var _stack_size := int(ItemData.item_data[item_name]["StackSize"])
			var _able_to_add: int = _stack_size - inventory[i][1]
			if _able_to_add >= item_quantity:
				inventory[i][1] += item_quantity
				return
			else:
				inventory[i][1] += _able_to_add
				item_quantity -= _able_to_add
				# because of the loop excess items will be added to next slot with the same item
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i: int in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			inventory[i] = [item_name, item_quantity]
			return


# TODO: is item argument necessary? slot.item should be the same
# (only when this function is called after put_into_slot in inventory.gd) 
func add_item_to_empty_slot(item: Item, slot: Slot) -> void:
	inventory[slot.index] = [item.item_name, item.item_quantity]


func remove_item(slot: Slot) -> void:
	inventory.erase(slot.index)


func add_item_quantity(slot: Slot, quantity: int) -> void:
	inventory[slot.index][1] += quantity
