class_name GravityField
extends Area2D

# TODO: consider creating separate layer for player body
# hurtbox area is disabled during dashing/invincibility
# for now, player's body is added to PlayerHurtbox layer

@export var direction := GlobalVariables.Directions.DOWN


func _ready() -> void:
	$Particles.amount *= scale.x
	$Particles.speed_scale /= scale.y


func _on_body_entered(body: Node2D) -> void:
	Logger.debug("Player entered gravity field")
	var player := body as Player
	player.set_gravity_direction(direction)


func _on_body_exited(body: Node2D) -> void:
	Logger.debug("Player exited gravity field")
	var player := body as Player
	player.set_gravity_direction(GlobalVariables.Directions.DOWN)
