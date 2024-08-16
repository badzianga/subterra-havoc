# Base class for all states used by Enemy State Machine.
# Used only for inheritance.

class_name State
extends Node

@warning_ignore("unused_signal")
signal state_finished  # emitted by derived classes


# All states should be disabled by default, so only one state can work
# simultaneously. To call it in derived classes, use super._ready().
func _ready() -> void:
	set_physics_process(false)


# Enables physics processing. Should be called in enter_state() methods of
# derived classes.
func _enter_state() -> void:
	set_physics_process(true)


# Disables physics processing. Should be called in exit_state() methods of
# derived classes.
func _exit_state() -> void:
	set_physics_process(false)
