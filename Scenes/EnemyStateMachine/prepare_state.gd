class_name PrepareState
extends State

signal player_lost
signal preparing_finished

@export var _actor: CharacterBody2D
@export var _animator: AnimationPlayer
@export var _vision_cast: RayCast2D
@export var _sprite: Sprite2D
@export var _state_label: Label
@export var _prepare_time: float

@onready var _prepare_timer := $PrepareTimer

var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	super._ready()
	assert(_prepare_time > 0)
	_prepare_timer.wait_time = _prepare_time


func _physics_process(delta: float) -> void:
	if not _actor.is_on_floor():
		_actor.velocity.y += _gravity * delta
	_actor.move_and_slide()
	
	_sprite.flip_h = _actor.global_position.x < GlobalVariables.player.global_position.x
	
	if _vision_cast.is_colliding() or not _actor.player_in_detection_area:
		_prepare_timer.stop()
		player_lost.emit()


func enter_state() -> void:
	_enter_state()
	_animator.play("prepare")
	_state_label.text = "State: prepare"
	_prepare_timer.start()


func exit_state() -> void:
	_exit_state()


func _on_prepare_timer_timeout() -> void:
	preparing_finished.emit()
