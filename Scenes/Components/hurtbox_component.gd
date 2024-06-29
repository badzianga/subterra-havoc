# Component for detecting collisions with hitboxes used by all entities.
#
# To use, set collision layer and/or mask and add CollisionShape as child.
# Also, assign HealthComponent variable to apply damage from hitboxes.

class_name HurtboxComponent
extends Area2D

@export var _health_component: HealthComponent


func _ready() -> void:
	assert(_health_component != null)


func _on_area_entered(hitbox: HitboxComponent) -> void:
	_health_component.apply_damage(hitbox.damage)
