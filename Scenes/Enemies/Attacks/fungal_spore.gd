extends HitboxComponent

@export var speed := 100.0

var direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
	global_position += direction * (speed * delta)


func _on_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
