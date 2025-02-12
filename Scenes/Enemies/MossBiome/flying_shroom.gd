extends Enemy

const FungalSporeScene := preload("res://Scenes/Enemies/Attacks/fungal_spore.tscn")

@onready var esm := $EnemyStateMachine as EnemyStateMachine
@onready var idle := $EnemyStateMachine/FlyingIdleState as FlyingIdleState
@onready var wander := $EnemyStateMachine/FlyingWanderState as FlyingWanderState
@onready var prepare := $EnemyStateMachine/FlyingPrepareState as FlyingPrepareState
@onready var attack := $EnemyStateMachine/FlyingAttackState as FlyingAttackState
@onready var cooldown := $EnemyStateMachine/FlyingCooldownState as FlyingCooldownState

@onready var sprite := $Sprite
@onready var detection_area := $DetectionArea
@onready var vision_cast := $VisionCast

const angles: Array[Array] = [
	[0.0],
	[deg_to_rad(-10.0), deg_to_rad(10.0)],
	[deg_to_rad(-20.0), 0.0, deg_to_rad(20.0)]
]


func _ready() -> void:
	idle.idling_finished.connect(esm.change_state.bind(wander))
	idle.player_seen.connect(esm.change_state.bind(prepare))
#
	wander.player_seen.connect(esm.change_state.bind(prepare))
	wander.wandering_finished.connect(esm.change_state.bind(idle))
#
	prepare.player_lost.connect(esm.change_state.bind(idle))
	prepare.preparing_finished.connect(esm.change_state.bind(attack))
#
	attack.attacking_finished.connect(esm.change_state.bind(cooldown))
#
	cooldown.cooldown_finished.connect(esm.change_state.bind(wander))
	cooldown.player_seen.connect(esm.change_state.bind(prepare))


func _physics_process(_delta: float) -> void:
	vision_cast.target_position = to_local(GlobalVariables.player.global_position)


func flip(flip_to_right: bool) -> void:
	sprite.flip_h = flip_to_right


# TODO: create more spores, maybe randomize amount of spores - 1-3 per attack
# also add proper bullet dispersion
func _attack() -> void:
	var amount := randi_range(1, 3)
	for i in range(amount):
		var fungal_spore := FungalSporeScene.instantiate()
		fungal_spore.global_position = global_position
		var dir := global_position.direction_to(GlobalVariables.player.global_position)
		var angle := dir.angle() + randf_range(-0.1, 0.1) + (angles[amount - 1][i] as float)
		fungal_spore.direction = Vector2.from_angle(angle)
		fungal_spore.rotation = angle
		GlobalVariables.map_node.add_child(fungal_spore)


func _on_detection_area_area_entered(_area: Area2D) -> void:
	player_in_detection_area = true


func _on_detection_area_area_exited(_area: Area2D) -> void:
	player_in_detection_area = false


func _on_health_depleted() -> void:
	queue_free()
