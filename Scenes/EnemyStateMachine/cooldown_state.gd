# Enemy's cooldown state. When activated, waits a litle bit after previous state.
# Emits two types of signals - when cooldown is finished with or without player in detection area.

class_name CooldownState
extends State

signal cooldown_finished  # emitted after cooldown without player in detection area
signal player_seen  # emitted when player is seen after cooldown

@export var _actor: Enemy
@export var _animator: AnimationPlayer
@export var _state_label: Label
@export var _cooldown_time: float

@onready var _cooldown_timer := $CooldownTimer


func _ready() -> void:
	super._ready()
	assert(_cooldown_time > 0)
	_cooldown_timer.wait_time = _cooldown_time


func _physics_process(delta: float) -> void:
	_actor.apply_gravity(delta)
	_actor.move_and_slide()


func enter_state() -> void:
	_enter_state()
	_animator.play("idle")
	_state_label.text = "State: cooldown"
	_cooldown_timer.start()


func exit_state() -> void:
	_exit_state()


func _on_cooldown_timer_timeout() -> void:
	if _actor.player_in_detection_area:
		player_seen.emit()
	else:
		cooldown_finished.emit()
