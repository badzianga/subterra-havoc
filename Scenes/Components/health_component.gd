class_name HealthComponent
extends Node2D

signal health_changed
signal health_depleted

@export var max_health: int

var health := 0


func _ready() -> void:
	health = max_health


func apply_damage(amount: int) -> void:
	health -= amount
	health_changed.emit()
	if health <= 0:
		health_depleted.emit()
