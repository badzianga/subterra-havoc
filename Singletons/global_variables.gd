extends Node

var player: Player
var user_interface_node: UserInterface
var inventory_node: Inventory
var map_node: Map


func clear_all() -> void:
	player = null
	user_interface_node = null
	inventory_node = null
	map_node = null
