class_name ShockWave
extends HitboxComponent

const SPEED := 100.0

var direction := Vector2.ZERO


func _ready() -> void:
	$Timer.start()


func flip(flip_to_right: bool) -> void:
	$Sprite.flip_h = flip_to_right


func _physics_process(delta: float) -> void:
	global_position += direction * (SPEED * delta)


func _on_timer_timeout() -> void:
	queue_free()
