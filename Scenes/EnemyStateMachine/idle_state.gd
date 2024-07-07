# Basic idle state for enemies. Starts idle timer and waits for the timeout.
# Immediately emits signal when detects player.

class_name IdleState
extends State

signal idling_finished
signal player_seen

@export var _actor: Enemy
@export var _animator: AnimationPlayer
@export var _state_label: Label
@export var _idle_time_min: float
@export var _idle_time_max: float

@onready var _idle_timer := $IdleTimer


func _ready() -> void:
	super._ready()
	assert(_idle_time_min > 0 and _idle_time_min <= _idle_time_max)


func _physics_process(delta: float) -> void:
	_actor.apply_gravity(delta)
	_actor.move_and_slide()
	
	if _actor.player_in_detection_area:
		_idle_timer.stop()
		player_seen.emit()


func enter_state() -> void:
	_enter_state()
	_animator.play("idle")
	_state_label.text = "State: idle"
	_idle_timer.wait_time = randf_range(_idle_time_min, _idle_time_max)
	_idle_timer.start()


func exit_state() -> void:
	_exit_state()


func _on_idle_timer_timeout() -> void:
	idling_finished.emit()
