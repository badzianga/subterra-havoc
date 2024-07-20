class_name RangedWeapon
extends Sprite2D

const ArrowScene := preload("res://Scenes/Weapons/wooden_arrow.tscn")

var _can_attack := true

@onready var _cooldown_timer := $CooldownTimer


func attack(direction: Vector2) -> void:
	_can_attack = false
	_shoot(direction)
	_cooldown_timer.start()
	await _cooldown_timer.timeout
	_can_attack = true


func can_attack() -> bool:
	return _can_attack


func _shoot(direction: Vector2) -> void:
	var arrow := ArrowScene.instantiate() as Projectile
	arrow.global_position = global_position
	arrow.rotation = PI + direction.angle()
	arrow.direction = direction
	GlobalVariables.world_node.call_deferred("add_child", arrow)
