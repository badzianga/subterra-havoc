# Typical attack state for chargers/dashers. Activates hitbox and moves faster.
# Emits signal when charge time runs out or actor collides with wall.

class_name ChargeState
extends State

signal charging_finished

@export var _actor: Enemy
@export var _animator: AnimationPlayer
@export var _hitbox_collision_shape: CollisionShape2D
@export var _state_label: Label
@export var _charge_time: float
@export var _charging_speed := 600.0

@onready var _charge_timer := $ChargeTimer


func _ready() -> void:
	super._ready()
	assert(_charge_time > 0)
	_charge_timer.wait_time = _charge_time


func _physics_process(delta: float) -> void:
	_actor.apply_gravity(delta)
	# stop charging when collision with wall occurs
	if _actor.is_on_wall():
		_charge_timer.stop()
		charging_finished.emit()
	_actor.move_and_slide()


func enter_state() -> void:
	_enter_state()
	_animator.play("charge")
	_state_label.text = "State: charge"
	_charge_timer.start()
	
	_hitbox_collision_shape.set_deferred("enabled", false)
	
	if GlobalVariables.player.global_position.x >= _actor.global_position.x:
		_actor.direction.x = 1.0
	else:
		_actor.direction.x = -1.0
	_actor.velocity.x = _actor.direction.x * _charging_speed


func exit_state() -> void:
	_actor.velocity.x = 0.0
	_hitbox_collision_shape.set_deferred("disabled", true)
	_exit_state()


func _on_charge_timer_timeout() -> void:
	charging_finished.emit()
