class_name FlyingWanderState
extends State

signal wandering_finished
signal player_seen

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var state_label: Label
@export var vision_cast: RayCast2D
@export var wander_cast: RayCast2D
@export var wandering_speed := 100.0

var wander_length: float
var path_wandered: float


func _ready() -> void:
	wander_length = wander_cast.target_position.length()
	super._ready()


func _physics_process(delta: float) -> void:
	actor.move_and_slide()
	# TODO: I was a little bit sleepy when I was writing it, so I couldn't
	# remember how to do that better, refactor it
	path_wandered += (actor.velocity * delta).length()
	if path_wandered >= wander_length:
		wandering_finished.emit()
	
	if actor.player_in_detection_area:
		if not vision_cast.is_colliding():
			player_seen.emit()
		# TODO: test if statements with state change should end with return


func enter_state() -> void:
	_enter_state()
	animator.play("wander")
	if state_label != null:
		state_label.text = name
	
	# TODO: this method of selecting random direction is really bad, especially
	# when enemy will be in some cramped space, consider changing it 
	var can_move := false
	while not can_move:
		wander_cast.target_position = wander_cast.target_position.rotated(randf_range(-PI, PI))
		wander_cast.force_raycast_update()
		if not wander_cast.is_colliding():
			can_move = true
	actor.direction = wander_cast.target_position.normalized()
	actor.velocity = actor.direction * wandering_speed
	actor.flip(actor.direction.x > 0.0)
	path_wandered = 0.0


func exit_state() -> void:
	actor.velocity = Vector2.ZERO
	_exit_state()
