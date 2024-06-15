class_name ChargeState
extends State

signal charging_finished

@export var _actor: Enemy
@export var _animator: AnimationPlayer
@export var _hitbox_collision_shape: CollisionShape2D
@export var _state_label: Label
@export var _charge_time: float

@onready var _charge_timer := $ChargeTimer

var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var _speed := 600.0
var _direction: float


func _ready() -> void:
	super._ready()
	assert(_charge_time > 0)
	_charge_timer.wait_time = _charge_time


func _physics_process(delta: float) -> void:
	if not _actor.is_on_floor():
		_actor.velocity.y += _gravity * delta
	if _actor.is_on_wall():
		_charge_timer.stop()
		charging_finished.emit()
	_actor.move_and_slide()


func enter_state() -> void:
	_enter_state()
	_animator.play("charge")
	_state_label.text = "State: charge"
	_charge_timer.start()
	
	_hitbox_collision_shape.set_deferred("disabled", false)
	
	if GlobalVariables.player.global_position.x >= _actor.global_position.x:
		_direction = 1.0
	else:
		_direction = -1.0
	_actor.velocity.x = _direction * _speed


func exit_state() -> void:
	_actor.velocity.x = 0.0
	_hitbox_collision_shape.set_deferred("disabled", true)
	_exit_state()


func _on_charge_timer_timeout() -> void:
	charging_finished.emit()
