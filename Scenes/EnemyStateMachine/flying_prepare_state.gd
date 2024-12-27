class_name FlyingPrepareState
extends State

signal player_lost
signal preparing_finished

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var state_label: Label
@export var vision_cast: RayCast2D
@export var prepare_time: float

@onready var prepare_timer := $PrepareTimer


func _ready() -> void:
	super._ready()
	assert(prepare_time > 0)
	prepare_timer.wait_time = prepare_time


func _physics_process(_delta: float) -> void:
	if not actor.player_in_detection_area or vision_cast.is_colliding():
		prepare_timer.stop()
		player_lost.emit()


func enter_state() -> void:
	_enter_state()
	animator.play("prepare")
	if state_label != null:
		state_label.text = name
	prepare_timer.start()


func exit_state() -> void:
	_exit_state()


func _on_prepare_timer_timeout() -> void:
	preparing_finished.emit()
