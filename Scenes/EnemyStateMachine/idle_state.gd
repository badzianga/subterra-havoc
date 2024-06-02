class_name IdleState
extends State

signal idling_finished
signal player_seen

@export var _actor: Enemy
@export var _animator: AnimationPlayer
@export var _vision_cast: RayCast2D
@export var _state_label: Label
@export var _idle_time_min: float
@export var _idle_time_max: float

@onready var _idle_timer := $IdleTimer

var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	super._ready()
	assert(_idle_time_min > 0 and _idle_time_min <= _idle_time_max)
	_idle_timer.wait_time = randf_range(_idle_time_min, _idle_time_max)


func _physics_process(delta: float) -> void:
	if not _actor.is_on_floor():
		_actor.velocity.y += _gravity * delta
	_actor.move_and_slide()
	
	if not _vision_cast.is_colliding() and _actor.player_in_detection_area:
		_idle_timer.stop()
		player_seen.emit()


func enter_state() -> void:
	_enter_state()
	_animator.play("idle")
	_state_label.text = "State: idle"
	_idle_timer.start()


func exit_state() -> void:
	_exit_state()


func _on_idle_timer_timeout() -> void:
	idling_finished.emit()
