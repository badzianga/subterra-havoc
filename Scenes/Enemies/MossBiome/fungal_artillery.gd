extends Enemy

@onready var esm := $EnemyStateMachine as EnemyStateMachine
@onready var idle := $EnemyStateMachine/IdleState as IdleState
@onready var wander := $EnemyStateMachine/WanderState as WanderState
@onready var prepare := $EnemyStateMachine/PrepareState as PrepareState
@onready var attack := $EnemyStateMachine/AttackState as AttackState
@onready var cooldown := $EnemyStateMachine/CooldownState as CooldownState

@onready var sprite := $Sprite
@onready var detection_area := $DetectionArea


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


func flip(flip_to_right: bool) -> void:
	sprite.flip_h = flip_to_right
	var flip_value := Vector2(1.0, 1.0)
	if flip_to_right:
		flip_value.x *= -1.0
	detection_area.set_deferred("scale", flip_value)


func _attack() -> void:
	pass


func _on_detection_area_area_entered(_area: Area2D) -> void:
	player_in_detection_area = true


func _on_detection_area_area_exited(_area: Area2D) -> void:
	player_in_detection_area = false


func _on_health_depleted() -> void:
	queue_free()
