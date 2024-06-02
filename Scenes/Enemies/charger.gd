extends Enemy

@onready var esm := $EnemyStateMachine as EnemyStateMachine
@onready var idle_state := $EnemyStateMachine/IdleState as IdleState
@onready var wander_state := $EnemyStateMachine/WanderState as WanderState
@onready var prepare_state := $EnemyStateMachine/PrepareState as PrepareState
@onready var charge_state := $EnemyStateMachine/ChargeState as ChargeState
@onready var cooldown_state := $EnemyStateMachine/CooldownState as CooldownState

@onready var vision_cast := $VisionCast


func _ready() -> void:
	_connect_states()


func _physics_process(_delta: float) -> void:
	vision_cast.look_at(GlobalVariables.player.global_position)


func _connect_states() -> void:
	idle_state.idling_finished.connect(esm.change_state.bind(wander_state))
	idle_state.player_seen.connect(esm.change_state.bind(prepare_state))
	
	wander_state.wandering_finished.connect(esm.change_state.bind(idle_state))
	wander_state.player_seen.connect(esm.change_state.bind(prepare_state))
	
	prepare_state.player_lost.connect(esm.change_state.bind(cooldown_state))
	prepare_state.preparing_finished.connect(esm.change_state.bind(charge_state))
	
	charge_state.charging_finished.connect(esm.change_state.bind(cooldown_state))
	
	cooldown_state.cooldown_finished.connect(esm.change_state.bind(wander_state))
	cooldown_state.player_seen.connect(esm.change_state.bind(prepare_state))


func _on_detection_area_area_entered(_area: Area2D) -> void:
	player_in_detection_area = true


func _on_detection_area_area_exited(_area: Area2D) -> void:
	player_in_detection_area = false
