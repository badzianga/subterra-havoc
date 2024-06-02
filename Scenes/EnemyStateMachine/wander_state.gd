class_name WanderState
extends State

signal wandering_finished
signal player_seen

@export var _actor: Enemy
@export var _animator: AnimationPlayer
@export var _vision_cast: RayCast2D
@export var _sprite: Sprite2D
@export var _state_label: Label
@export var _wander_time_min: float
@export var _wander_time_max: float

@onready var _wander_timer := $WanderTimer

var _gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var _speed := 200.0
var _direction: float


func _ready() -> void:
	super._ready()
	assert(_wander_time_min > 0 and _wander_time_min <= _wander_time_max)
	_wander_timer.wait_time = randf_range(_wander_time_min, _wander_time_max)


func _physics_process(delta: float) -> void:
	if not _actor.is_on_floor():
		_actor.velocity.y += _gravity * delta
	if _actor.is_on_wall():
		_direction *= -1.0
		_actor.velocity.x = _direction * _speed
		# TODO: with flip, change sprite position because Max cannot draw centered images
		_sprite.flip_h = (_direction > 0.0)
		_sprite.position.x = 8.0 - 16.0 * float(_direction > 0.0)
	_actor.move_and_slide()
	
	if not _vision_cast.is_colliding() and _actor.player_in_detection_area:
		_wander_timer.stop()
		player_seen.emit()
		# TODO: statements with state change should end with return?


func enter_state() -> void:
	_enter_state()
	_animator.play("walk")
	_state_label.text = "State: wander"
	_wander_timer.start()
	
	if randf() < 0.5:
		_direction = 1.0
	else:
		_direction = -1.0
	_actor.velocity.x = _direction * _speed
	# TODO: with flip, change sprite position because Max cannot draw centered images
	_sprite.flip_h = (_direction > 0.0)
	_sprite.position.x = 8.0 - 16.0 * float(_direction > 0.0)


func exit_state() -> void:
	_actor.velocity.x = 0.0
	_exit_state()


func _on_wander_timer_timeout() -> void:
	wandering_finished.emit()
