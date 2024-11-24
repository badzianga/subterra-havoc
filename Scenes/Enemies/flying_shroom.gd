# FIXME: when enemy finished dashing on the edge of the platform, so, only one of its raycasts
# touches ground, it changes direction every frame. To fix, making separate if statements for
# raycasts should probably be a good solution

extends Enemy

signal collided_with_edge

@onready var _esm := $EnemyStateMachine as EnemyStateMachine
@onready var _idle_state := $EnemyStateMachine/IdleState as IdleState
@onready var _wander_state := $EnemyStateMachine/WanderState as WanderState
@onready var _prepare_state := $EnemyStateMachine/PrepareState as PrepareState
@onready var _charge_state := $EnemyStateMachine/ChargeState as ChargeState
@onready var _cooldown_state := $EnemyStateMachine/CooldownState as CooldownState
@onready var _health_component := $HealthComponent as HealthComponent
@onready var _left_edge_ray_cast := $LeftEdgeRayCast
@onready var _right_edge_ray_cast := $RightEdgeRayCast


func _ready() -> void:
	_connect_states()
	
	_health_component.health_depleted.connect(_on_health_depleted)


func _physics_process(_delta: float) -> void:
	if is_on_floor():
		if not _left_edge_ray_cast.is_colliding() or not _right_edge_ray_cast.is_colliding():
			collided_with_edge.emit()


func _connect_states() -> void:
	_idle_state.idling_finished.connect(_esm.change_state.bind(_wander_state))
	_idle_state.player_seen.connect(_esm.change_state.bind(_prepare_state))
	
	_wander_state.wandering_finished.connect(_esm.change_state.bind(_idle_state))
	_wander_state.player_seen.connect(_esm.change_state.bind(_prepare_state))
	
	_prepare_state.player_lost.connect(_esm.change_state.bind(_cooldown_state))
	_prepare_state.preparing_finished.connect(_esm.change_state.bind(_charge_state))
	
	_charge_state.charging_finished.connect(_esm.change_state.bind(_cooldown_state))
	
	_cooldown_state.cooldown_finished.connect(_esm.change_state.bind(_wander_state))
	_cooldown_state.player_seen.connect(_esm.change_state.bind(_prepare_state))


func _on_detection_area_area_entered(_area: Area2D) -> void:
	player_in_detection_area = true


func _on_detection_area_area_exited(_area: Area2D) -> void:
	player_in_detection_area = false


func _on_health_depleted() -> void:
	queue_free()
