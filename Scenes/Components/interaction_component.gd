# TODO: join InteractionComponent and LootingComponent into one component?
# TODO: show E key on screen to indicate that player can interact with object

class_name InteractionComponent
extends Area2D

var interactable: Area2D


func _on_area_entered(area: Area2D) -> void:
	interactable = area
	Logger.debug("Can interact with object: " + area.name)


func _on_area_exited(area: Area2D) -> void:
	interactable = null
	Logger.debug("Object: " + area.name + " left the range")
