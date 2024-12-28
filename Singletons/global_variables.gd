# Singleton for holding all references to rather important nodes used by another
# nodes without the need to use slow and bug-prone get_parent()/get_child()

# TODO: change name to Global instead of GlobalVariables
# TODO: tidy up folder structure
# TODO: change game resolution

extends Node

var player: Player
var user_interface_node: UserInterface
var inventory_node: Inventory
var map_node: Map


# Clear all references to previous nodes - just to make sure if some node is not
# updated, it will cause crash rather instead of unpredictable behavior.
func clear_all() -> void:
	player = null
	user_interface_node = null
	inventory_node = null
	map_node = null
