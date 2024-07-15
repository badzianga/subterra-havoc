class_name MeleeWeapon
extends Sprite2D

var _can_attack := true

@onready var _animation_player := $AnimationPlayer
@onready var _hitbox_collider := $HitboxComponent/CollisionShape


func attack(_direction: Vector2) -> void:
	_can_attack = false
	_animation_player.play("attack")
	await _animation_player.animation_finished
	_can_attack = true


func can_attack() -> bool:
	return _can_attack


# Called by animation player.
func _enable_collider() -> void:
	_hitbox_collider.set_deferred("disabled", false)


# Called by animation player.
func _disable_collider() -> void:
	_hitbox_collider.set_deferred("disabled", true)
