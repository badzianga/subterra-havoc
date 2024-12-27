class_name FlyingIdleState
extends State

signal idling_finished
signal player_seen

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var state_label: Label
@export var vision_cast: RayCast2D
@export var idle_time_min: float
@export var idle_time_max: float

@onready var idle_timer := $IdleTimer


func _ready() -> void:
	super._ready()
	assert(idle_time_min > 0 and idle_time_min <= idle_time_max)


func _physics_process(_delta: float) -> void:
	if actor.player_in_detection_area:
		if not vision_cast.is_colliding():
			idle_timer.stop()
			player_seen.emit()


func enter_state() -> void:
	_enter_state()
	animator.play("idle")
	if state_label != null:
		state_label.text = name
	idle_timer.wait_time = randf_range(idle_time_min, idle_time_max)
	idle_timer.start()


func exit_state() -> void:
	_exit_state()


func _on_idle_timer_timeout() -> void:
	idling_finished.emit()
