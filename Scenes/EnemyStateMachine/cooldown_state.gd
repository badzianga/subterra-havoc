class_name CooldownState
extends State

signal cooldown_finished
signal player_seen

@export var _actor: Enemy
@export var _animator: AnimationPlayer
@export var _vision_cast: RayCast2D
@export var _state_label: Label
@export var _cooldown_time: float

@onready var _cooldown_timer := $CooldownTimer

var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	super._ready()
	assert(_cooldown_time > 0)
	_cooldown_timer.wait_time = _cooldown_time


func _physics_process(delta: float) -> void:
	if not _actor.is_on_floor():
		_actor.velocity.y += _gravity * delta
	_actor.move_and_slide()


func enter_state() -> void:
	_enter_state()
	_animator.play("idle")
	_state_label.text = "State: cooldown"
	_cooldown_timer.start()


func exit_state() -> void:
	_exit_state()


func _on_cooldown_timer_timeout() -> void:
	if not _vision_cast.is_colliding() and _actor.player_in_detection_area:
		player_seen.emit()
	else:
		cooldown_finished.emit()
