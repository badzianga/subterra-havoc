extends Sprite2D

@onready var _animation_player := $AnimationPlayer
@onready var _hitbox_collider := $HitboxComponent/CollisionShape


func attack() -> void:
	_animation_player.play("attack")
	await _animation_player.animation_finished


func _enable_collider() -> void:
	_hitbox_collider.set_deferred("disabled", false)


func _disable_collider() -> void:
	_hitbox_collider.set_deferred("disabled", true)
