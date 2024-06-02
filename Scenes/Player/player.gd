class_name Player
extends CharacterBody2D


const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var health_component := $HealthComponent as HealthComponent
@onready var health_bar := $HealthBar


func _ready() -> void:
	GlobalVariables.player = self
	health_bar.max_value = health_component.max_health


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_health_component_health_changed() -> void:
	health_bar.value = health_component.health


func _on_health_component_health_depleted() -> void:
	set_physics_process(false)
