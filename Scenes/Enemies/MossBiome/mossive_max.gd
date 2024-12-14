# TODO: now I'm raping DRY principle, so i think it would be a good idea to
# create function in enemy class for easy state connecting by using dictionary
# or something like that - but how to use different signals? Maybe by using
# .get (I think it was named like that)
# TODO: player dodgind disables hurtbox, so enemies can't see player
# this is rather undesirable behavior, so I think player's body should
# exist on another collision layer
extends Enemy

const ShockWaveScene := preload("res://Scenes/Enemies/Attacks/shock_wave.tscn")

@onready var esm := $EnemyStateMachine as EnemyStateMachine
@onready var idle := $EnemyStateMachine/IdleState as IdleState
@onready var wander := $EnemyStateMachine/WanderState as WanderState
@onready var prepare := $EnemyStateMachine/PrepareState as PrepareState
@onready var attack := $EnemyStateMachine/AttackState as AttackState
@onready var cooldown := $EnemyStateMachine/CooldownState as CooldownState

@onready var hurtbox_collider := $HurtboxComponent/CollisionShape
@onready var hitbox_collider := $HitboxComponent/CollisionShape
@onready var sprite := $Sprite
@onready var detection_area := $DetectionArea
@onready var hitbox_component := $HitboxComponent
@onready var dust_cloud_particles := $DustCloudParticles


func _ready() -> void:
	idle.idling_finished.connect(esm.change_state.bind(wander))
	idle.player_seen.connect(esm.change_state.bind(prepare))

	wander.player_seen.connect(esm.change_state.bind(prepare))
	wander.wandering_finished.connect(esm.change_state.bind(idle))

	prepare.player_lost.connect(esm.change_state.bind(idle))
	prepare.preparing_finished.connect(esm.change_state.bind(attack))

	attack.attacking_finished.connect(esm.change_state.bind(cooldown))

	cooldown.cooldown_finished.connect(esm.change_state.bind(wander))
	cooldown.player_seen.connect(esm.change_state.bind(prepare))


# INFO: flipping overrides dust cloud particles position.x
func flip(flip_to_right: bool) -> void:
	sprite.flip_h = flip_to_right
	var flip_value := Vector2(1.0, 1.0)
	if flip_to_right:
		flip_value.x *= -1.0
	hitbox_component.set_deferred("scale", flip_value)
	detection_area.set_deferred("scale", flip_value)
	dust_cloud_particles.position.x = -flip_value.x * 32.0


func _create_shock_wave(dir: float) -> void:
	var shock_wave := ShockWaveScene.instantiate()
	shock_wave.direction.x = dir
	shock_wave.global_position = global_position
	GlobalVariables.map_node.add_child(shock_wave)


func _attack() -> void:
	hurtbox_collider.set_deferred("disabled", false)
	hitbox_collider.set_deferred("disabled", false)
	_create_shock_wave(-1.0)
	_create_shock_wave(1.0)
	dust_cloud_particles.emitting = true


func _disable_hitbox_collider() -> void:
	hitbox_collider.set_deferred("disabled", true)


func _disable_hurtbox_collider() -> void:
	hurtbox_collider.set_deferred("disabled", true)


func _on_detection_area_area_entered(_area: Area2D) -> void:
	player_in_detection_area = true


func _on_detection_area_area_exited(_area: Area2D) -> void:
	player_in_detection_area = false


func _on_health_depleted() -> void:
	queue_free()
