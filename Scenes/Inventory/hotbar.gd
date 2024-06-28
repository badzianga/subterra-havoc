extends Control

@onready var slots := $Background/Slots.get_children()


func _ready() -> void:
	for i: int in range(slots.size()):
		slots[i].index = i
	_initialize_inventory()


func _initialize_inventory() -> void:
	for i in range(slots.size()):
		# TODO: change hotbar to inventory later, and do some magic so the hotbar will be shortcut
		# to inventory instead of separate inventory
		if not PlayerInventory.hotbar.has(i):
			return
		slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])
