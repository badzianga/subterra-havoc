# Enemies' wandering state. When activated, moves actor on map while checking
# collisions until sees the player or until randomized time runs out.
#
# TODO: add checking platform ends with RayCasts

class_name WanderState
extends State

signal wandering_finished
signal player_seen

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var sprite: Sprite2D
@export var detection_area: Area2D
@export var state_label: Label
@export var wander_time_min: float
@export var wander_time_max: float
@export var wandering_speed := 150.0

@onready var _wander_timer := $WanderTimer


func _ready() -> void:
	super._ready()
	assert(wander_time_min > 0 and wander_time_min <= wander_time_max)
	#if actor.has_signal("collided_with_edge"):
		#actor.collided_with_edge.connect(_on_collided_with_edge)


func _physics_process(delta: float) -> void:
	actor.apply_gravity(delta)
	if actor.is_on_wall():
		actor.direction.x *= -1.0
		actor.velocity.x = actor.direction.x * wandering_speed
		detection_area.rotation = float(sprite.flip_h) * PI
	actor.move_and_slide()
	
	if actor.player_in_detection_area:
		_wander_timer.stop()
		player_seen.emit()
		# TODO: test if statements with state change should end with return


func enter_state() -> void:
	_enter_state()
	animator.play("wander")
	if state_label != null:
		state_label.text = name
	_wander_timer.wait_time = randf_range(wander_time_min, wander_time_max)
	_wander_timer.start()
	
	if randf() < 0.5:
		actor.direction.x = 1.0
	else:
		actor.direction.x = -1.0
	actor.velocity.x = actor.direction.x * wandering_speed
	sprite.flip_h = (actor.direction.x > 0.0)
	detection_area.rotation = float(sprite.flip_h) * PI


func exit_state() -> void:
	actor.velocity.x = 0.0
	_exit_state()


func _on_wander_timer_timeout() -> void:
	wandering_finished.emit()


#func _on_collided_with_edge() -> void:
	#if _wander_timer.is_stopped():
		#return
	#actor.direction.x *= -1.0
	#actor.velocity.x = actor.direction.x * wandering_speed
	#sprite.flip_h = (actor.direction.x > 0.0)
	#sprite.position.x = 8.0 - 16.0 * float(actor.direction.x > 0.0)
	#detection_area.rotation = float(sprite.flip_h) * PI
