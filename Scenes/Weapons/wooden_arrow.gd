class_name Projectile
extends HitboxComponent

const SPEED := 400.0

var direction: Vector2


func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta 


func _on_area_entered(_area: Area2D) -> void:
	call_deferred("queue_free")
