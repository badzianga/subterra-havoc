# Resource used in ItemDropComponent's array to set drop chances of items.

class_name ItemDropInfo
extends Resource

@export var drop_id: String
@export_range(0, 1) var drop_chance: float
