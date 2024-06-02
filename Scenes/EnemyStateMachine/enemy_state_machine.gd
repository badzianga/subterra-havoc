class_name EnemyStateMachine
extends Node

@export var _state: State


func _ready() -> void:
	assert(_state != null)
	change_state(_state)


func change_state(new_state: State) -> void:
	if _state is State:  # TODO: this check might not be necessary
		_state.exit_state()
	new_state.enter_state()
	_state = new_state
