# TODO: now I'm raping DRY principle, so i think it would be a good idea to
# create function in enemy class for easy state connecting by using dictionary
# or something like that - but how to use different signals? Maybe by using
# .get (I think it was named like that)
extends Enemy

@onready var esm := $EnemyStateMachine as EnemyStateMachine
@onready var idle := $EnemyStateMachine/IdleState as IdleState
#@onready var wander := $EnemyStateMachine/WanderState as WanderState
#@onready var prepare := $EnemyStateMachine/PrepareState as PrepareState
#@onready var cooldown := $EnemyStateMachine/CooldownState as CooldownState
#@onready var attack := $EnemyStateMachine/AttackState as AttackState


func _ready() -> void:
	pass
	#idle.idling_finished.connect(esm.change_state.bind(wander))
	#idle.player_seen.connect(esm.change_state.bind(prepare))
	#
	#wander.player_seen.connect(esm.change_state.bind(prepare))
	#wander.wandering_finished.connect(esm.change_state.bind(idle))
	#
	#prepare.player_lost.connect(esm.change_state.bind(idle))
	#prepare.preparing_finished.connect(esm.change_state.bind(attack))
#
	#attack.attacking_finished.connect(esm.change_state.bind(cooldown))
	#
	#cooldown.cooldown_finished.connect(esm.change_state.bind(idle))
	#cooldown.player_seen.connect(esm.change_state.bind(prepare))


func _on_health_depleted() -> void:
	queue_free()
