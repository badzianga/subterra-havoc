# Singleton used for handling inventory dictionaries (proper items, not visual representation).
# It also has some variables used by inventories - e.g. held_item, so items can be moved between
# inventories.
#
# TODO: I'm not pretty sure if scrolling should be here - maybe it will be better in hotbar script

extends Node

signal active_item_updated

# TODO: load there numbers from inventory scenes OR create these amount of slots in scenes 
const NUM_INVENTORY_SLOTS := 24
const NUM_HOTBAR_SLOTS := 4

var inventory := {
	0: ["oreGold", 15],  # slot_index: [item_id, item_quantity]
	1: ["bowWooden", 1],
	2: ["arrowWooden", 10],
}
var hotbar := {
	0: ["spearBronze", 1],
}
var equips := {}

var active_item_slot := 0
var held_item: Item


# Called by ItemDrop. Adds item to the inventory dictionary. 
# TODO: _update_slot_visual might be redundant here.
func collect_item(item_id: String, item_quantity: int) -> void:
	for i: int in inventory.keys():
		if inventory[i][0] == item_id:
			var _stack_size := int(ItemData.item_data[item_id]["StackSize"])
			var _able_to_add: int = _stack_size - inventory[i][1]
			if _able_to_add >= item_quantity:
				inventory[i][1] += item_quantity
				#_update_slot_visual(i, inventory[i][0], inventory[i][1])
				return
			else:
				inventory[i][1] += _able_to_add
				#_update_slot_visual(i, inventory[i][0], inventory[i][1])
				item_quantity -= _able_to_add
				# because of the loop excess items will be added to next slot with the same item
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i: int in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			inventory[i] = [item_id, item_quantity]
			#_update_slot_visual(i, inventory[i][0], inventory[i][1])
			return


# Adds item to empty slot in proper dictionary depending on slot's type.
# TODO: is item argument necessary? slot.item should be the same
# (only when this function is called after put_item_into_slot in inventory.gd) 
func add_item_to_empty_slot(item: Item, slot: Slot) -> void:
	match slot.slot_type:
		Slot.SlotType.HOTBAR:
			hotbar[slot.index] = [item.id, item.quantity]
		Slot.SlotType.INVENTORY:
			inventory[slot.index] = [item.id, item.quantity]
		_:
			equips[slot.index] = [item.id, item.quantity]


# Adds item from proper dictionary depending on slot's type.
func remove_item_from_slot(slot: Slot) -> void:
	match slot.slot_type:
		Slot.SlotType.HOTBAR:
			hotbar.erase(slot.index)
		Slot.SlotType.INVENTORY:
			inventory.erase(slot.index)
		_:
			equips.erase(slot.index)


# Adds item amount to proper slot in proper dictionary depending on slot's type.
func increase_item_quantity(slot: Slot, quantity: int) -> void:
	match slot.slot_type:
		Slot.SlotType.HOTBAR:
			hotbar[slot.index][1] += quantity
		Slot.SlotType.INVENTORY:
			inventory[slot.index][1] += quantity
		_:
			equips[slot.index][1] += quantity


# Moves active slot to the left.
func active_item_scroll_up() -> void:
	active_item_slot = posmod(active_item_slot - 1, NUM_HOTBAR_SLOTS)
	active_item_updated.emit()


# Moves active slot to the right.
func active_item_scroll_down() -> void:
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	active_item_updated.emit()


#func _update_slot_visual(slot_index: int, item_id: String, item_quantity: int) -> void:
	## TODO: this method might be unnecessary (if opening inventory will cause pause)
	## also, Inventory stored in variable in singleton might be a better idea
	## TODO: this method might be unnecessary, because toggling inventory calls initialize_inventory
	## which also calls initialize_item and/or set_item, delete this if make sure it can be removed 
	#var slot: Slot = GlobalVariables.inventory_node.inventory_slots.get_child(slot_index)
	#if slot.item != null:
		#slot.item.set_item(item_id, item_quantity)
	#else:
		#slot.initialize_item(item_id, item_quantity)
