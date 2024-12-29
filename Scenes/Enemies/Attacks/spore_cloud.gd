class_name SporeCloud
extends HitboxComponent

# TODO: movement logic can be simpler

const MIN_SPEED := 20.0
const MAX_SPEED := 60.0

@export var movement_curve: Curve

var direction := Vector2.LEFT
var speed: float

@onready var timer: Timer = $LifetimeTimer


func _ready() -> void:
	speed = randf_range(MIN_SPEED, MAX_SPEED)
	
	scale *= randf_range(0.8, 1.4)
	
	var color_disposition := 0.5
	var random := randf_range(0.0, color_disposition)
	modulate.r += random
	color_disposition -= random
	random = randf_range(0.0, color_disposition)
	modulate.g -= random
	color_disposition -= random
	modulate.b = color_disposition


func _physics_process(delta: float) -> void:
	var time := (timer.wait_time - timer.time_left) / timer.wait_time
	global_position += direction * (movement_curve.sample(time) * speed * delta)


func _on_lifetime_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property($Sprite, "modulate:a", 0.0, 0.25)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
