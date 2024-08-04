# Component used by all entities that have health points.
#
# Note that for proper working it needs some sort of collision checking to apply
# damage, so it is used as HurtboxComponent's export variable.
#
# After applying damage, it spawns damage indicator in its global_position, so
# make sure to posiiton it in the entity scene.
#
# Hurt effect or death should be implemented in entity's script using available
# signals.
#
# max_health and health are public variables, so they can be used externally.
# However, external modification of these variables won't emit signals.

class_name HealthComponent
extends Node2D

signal health_changed  # emitted when damage is applied
signal health_depleted  # emitted when lethal amount damage is applied

const DamageIndicatorScene := preload("res://Scenes/UI/damage_indicator.tscn")

@export var max_health: int

var health: int


func _ready() -> void:
	health = max_health


# Reduces entity's damage by amount passed as argument and emits signals.
# Also spawns damage indicators with applied damage.
func apply_damage(amount: int) -> void:
	health -= amount
	health_changed.emit()
	if health <= 0:
		health_depleted.emit()
	_spawn_damage_indicator(amount)


# Spawns animated damage indicator at the component's position.
func _spawn_damage_indicator(damage: int) -> void:
	var _indicator := DamageIndicatorScene.instantiate()
	_indicator.text = str(damage)
	_indicator.global_position += global_position
	GlobalVariables.map_node.add_child(_indicator)
