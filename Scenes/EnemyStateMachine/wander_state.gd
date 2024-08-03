# Enemies' wandering state. When activated, moves actor on map while checking
# collisions until sees the player or until randomized time runs out.
#
# TODO: add checking platform ends with RayCasts

class_name WanderState
extends State

signal wandering_finished
signal player_seen

@export var _actor: Enemy
@export var _animator: AnimationPlayer
@export var _sprite: Sprite2D
@export var _detection_area: Area2D
@export var _state_label: Label
@export var _wander_time_min: float
@export var _wander_time_max: float
@export var _wandering_speed := 150.0

@onready var _wander_timer := $WanderTimer


func _ready() -> void:
	super._ready()
	assert(_wander_time_min > 0 and _wander_time_min <= _wander_time_max)
	if _actor.has_signal("collided_with_edge"):
		_actor.collided_with_edge.connect(_on_collided_with_edge)


func _physics_process(delta: float) -> void:
	_actor.apply_gravity(delta)
	if _actor.is_on_wall():
		_actor.direction.x *= -1.0
		_actor.velocity.x = _actor.direction.x * _wandering_speed
		_sprite.flip_h = (_actor.direction.x > 0.0)
		# with flip, change sprite position because Max cannot draw centered images
		# HACK: this little hack will probably cause problems with sprites with other sizes 
		_sprite.position.x = 8.0 - 16.0 * float(_actor.direction.x > 0.0)
		# also flip player detection area
		_detection_area.rotation = float(_sprite.flip_h) * PI
		
	_actor.move_and_slide()
	
	if _actor.player_in_detection_area:
		_wander_timer.stop()
		player_seen.emit()
		# TODO: test if statements with state change should end with return


func enter_state() -> void:
	_enter_state()
	_animator.play("walk")
	_state_label.text = "State: wander"
	_wander_timer.wait_time = randf_range(_wander_time_min, _wander_time_max)
	_wander_timer.start()
	
	if randf() < 0.5:
		_actor.direction.x = 1.0
	else:
		_actor.direction.x = -1.0
	_actor.velocity.x = _actor.direction.x * _wandering_speed
	_sprite.flip_h = (_actor.direction.x > 0.0)
	# with flip, change sprite position because Max cannot draw centered images
	# HACK: this little hack will probably cause problems with sprites with other sizes 
	_sprite.position.x = 8.0 - 16.0 * float(_actor.direction.x > 0.0)
	# also flip player detection area
	_detection_area.rotation = float(_sprite.flip_h) * PI


func exit_state() -> void:
	_actor.velocity.x = 0.0
	_exit_state()


func _on_wander_timer_timeout() -> void:
	wandering_finished.emit()


func _on_collided_with_edge() -> void:
	if _wander_timer.is_stopped():
		return
	_actor.direction.x *= -1.0
	_actor.velocity.x = _actor.direction.x * _wandering_speed
	_sprite.flip_h = (_actor.direction.x > 0.0)
	_sprite.position.x = 8.0 - 16.0 * float(_actor.direction.x > 0.0)
	_detection_area.rotation = float(_sprite.flip_h) * PI
