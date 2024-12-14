# Enemies' attack state. When activated, executes an attack implemented in
# enemy's script. FUNCTION CALL SHOULD BE IN ATTACK ANIMATION.
# TODO: most of the logic in enemy script is the same. Only difference will
# probably be attacks, so maybe a good idea will be to use Strategy pattern.
# All enemies will have enemy.gd script and use attacks created using Strategy.
# There will be a node with specific attack.

class_name AttackState
extends State

signal attacking_finished

@export var animator: AnimationPlayer
@export var state_label: Label


func _ready() -> void:
	super._ready()


func enter_state() -> void:
	_enter_state()
	if state_label != null:
		state_label.text = name
	animator.play("attack")
	await animator.animation_finished
	attacking_finished.emit()


func exit_state() -> void:
	_exit_state()
