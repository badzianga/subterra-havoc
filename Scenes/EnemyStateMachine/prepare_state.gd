# Enemies' preparation state. When activated, waits for the timer's timeout to attack player.
# This time window gives player time to kill enemy, run away or prepare for block.
# State immediately emits signal when player leaves detection area.

class_name PrepareState
extends State

signal player_lost
signal preparing_finished

@export var _actor: Enemy
@export var _animator: AnimationPlayer
#@export var _sprite: Sprite2D
#@export var _detection_area: Area2D
@export var _state_label: Label
@export var _prepare_time: float

@onready var _prepare_timer := $PrepareTimer


func _ready() -> void:
	super._ready()
	assert(_prepare_time > 0)
	_prepare_timer.wait_time = _prepare_time


func _physics_process(delta: float) -> void:
	_actor.apply_gravity(delta)
	_actor.move_and_slide()
	
	# the commented logic below allows enemy to rotate to still see the player
	
	#_sprite.flip_h = (_actor.global_position.x < GlobalVariables.player.global_position.x)
	## with flip, change sprite position because Max cannot draw centered images
	## HACK: this little hack will probably cause problems with sprites with other sizes 
	#_sprite.position.x = 8.0 - 16.0 * float(_actor.direction.x > 0.0)
	## also flip player detection area
	#_detection_area.rotation = float(_sprite.flip_h) * PI
	
	if not _actor.player_in_detection_area:
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
