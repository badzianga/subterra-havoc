# Enemy State Machine used for enemies' AI.

class_name EnemyStateMachine
extends Node

@export var _state: State  # default/active state


# Enables default state.
func _ready() -> void:
	assert(_state != null)
	change_state(_state)


# Changes states by disabling old one and enabling new one.
func change_state(new_state: State) -> void:
	assert(_state is State)  # makes sure none of us forgets about setting default state
	_state.exit_state()
	new_state.enter_state()
	_state = new_state
