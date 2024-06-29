# Component used by all entities that have health points.
#
# Note that for proper working it needs some sort of collision checking to apply damage, so it is
# used as HurtboxComponent's export variable.
#
# Hurt effect or death should be implemented in entity's script using available signals.
#
# max_health and health are public variables, so they can be used externally.
# However, external modification of these variables won't emit signals.

class_name HealthComponent
extends Node2D

signal health_changed  # emitted when damage is applied
signal health_depleted  # emitted when lethal amount damage is applied

@export var max_health: int

var health: int


func _ready() -> void:
	health = max_health


# Reduces entity's damage by amount passed as argument and emits signals.
func apply_damage(amount: int) -> void:
	health -= amount
	health_changed.emit()
	if health <= 0:
		health_depleted.emit()
