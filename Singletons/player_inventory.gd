extends Node

# TODO: load this number from Inventory scene OR create these amount of slots in Inventory scene 
const NUM_INVENTORY_SLOTS := 20

var inventory: Dictionary = {
	0: ["Iron Sword", 1]  # slot_index: [item_name, item_quantity]
}


func add_item(item_name: String, item_quantity: int) -> void:
	for slot: int in inventory:
		if inventory[slot][0] == item_name:
			# TODO: check if slot is full
			inventory[slot][1] += item_quantity
			return
	
	for i: int in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			inventory[i] = [item_name, item_quantity]
			return
