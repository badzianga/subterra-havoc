# Enemy's cooldown state. When activated, waits a litle bit after previous state.
# Emits two types of signals - when cooldown is finished with or without player
# in detection area.

class_name CooldownState
extends State

signal cooldown_finished  # emitted after cooldown without player in detection area
signal player_seen  # emitted when player is seen after cooldown

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var state_label: Label
@export var cooldown_time: float

@onready var cooldown_timer := $CooldownTimer


func _ready() -> void:
	super._ready()
	assert(cooldown_time > 0)
	cooldown_timer.wait_time = cooldown_time


func _physics_process(delta: float) -> void:
	actor.apply_gravity(delta)
	actor.move_and_slide()


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
