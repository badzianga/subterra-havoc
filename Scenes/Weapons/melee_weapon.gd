class_name MeleeWeapon
extends Sprite2D

@onready var _animation_player := $AnimationPlayer
@onready var _hitbox_collider := $HitboxComponent/CollisionShape


func attack() -> void:
	_animation_player.play("attack")


# Called by animation player.
func _enable_collider() -> void:
	_hitbox_collider.set_deferred("disabled", false)


# Called by animation player.
func _disable_collider() -> void:
	_hitbox_collider.set_deferred("disabled", true)
