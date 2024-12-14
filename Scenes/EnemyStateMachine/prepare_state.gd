# Enemies' preparation state. When activated, waits for the timer's timeout to
# attack player.
# This time window gives player time to kill enemy, run away or prepare for
# block. State immediately emits signal when player leaves detection area.

class_name PrepareState
extends State

signal player_lost
signal preparing_finished

@export var actor: Enemy
@export var animator: AnimationPlayer
#@export var sprite: Sprite2D
#@export var detection_area: Area2D
@export var state_label: Label
@export var prepare_time: float

@onready var prepare_timer := $PrepareTimer


func _ready() -> void:
	super._ready()
	assert(prepare_time > 0)
	prepare_timer.wait_time = prepare_time


func _physics_process(delta: float) -> void:
	actor.apply_gravity(delta)
	actor.move_and_slide()
	
	# the commented logic below allows enemy to rotate to still see the player
	#_sprite.flip_h = (_actor.global_position.x < GlobalVariables.player.global_position.x)
	#_detection_area.rotation = float(_sprite.flip_h) * PI
	
	if not actor.player_in_detection_area:
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
