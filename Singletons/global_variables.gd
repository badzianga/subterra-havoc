extends Node

var player: Player
var user_interface_node: UserInterface
var inventory_node: Inventory
var world_node: Node2D


func clear_all() -> void:
	player = null
	user_interface_node = null
	inventory_node = null
	world_node = null
