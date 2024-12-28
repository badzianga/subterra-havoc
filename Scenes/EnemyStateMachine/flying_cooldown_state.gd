# Dummy state, is not doing anything, only wait.

class_name FlyingCooldownState
extends State

signal cooldown_finished
signal player_seen

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var state_label: Label
@export var cooldown_time: float

@onready var cooldown_timer := $CooldownTimer


func _ready() -> void:
	super._ready()
	assert(cooldown_time > 0)
	cooldown_timer.wait_time = cooldown_time


func enter_state() -> void:
	_enter_state()
	animator.play("idle")
	if state_label != null:
		state_label.text = name
	cooldown_timer.start()


func exit_state() -> void:
	_exit_state()


func _on_cooldown_timer_timeout() -> void:
	if actor.player_in_detection_area:
		player_seen.emit()
	else:
		cooldown_finished.emit()
