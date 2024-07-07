class_name Enemy
extends CharacterBody2D

var player_in_detection_area := false

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction := Vector2.ZERO


# Checks if Enemy is on the floor; if not, then applies gravity loaded from project settings
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
