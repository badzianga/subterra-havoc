class_name ItemDrop
extends CharacterBody2D

const ACCELERATION := 920.0
const MAX_SPEED := 450.0

var item_name: String
var _player: Player
var _being_picked_up := false


func _ready() -> void:
	item_name = "Slime Potion"


func _physics_process(delta: float) -> void:
	if not _being_picked_up:
		velocity = velocity.move_toward(Vector2(0, MAX_SPEED), ACCELERATION * delta)
	else:
		var _direction := global_position.direction_to(_player.global_position)
		velocity = velocity.move_toward(_direction * MAX_SPEED, ACCELERATION * delta)
		
		var _distance := global_position.distance_to(_player.global_position)
		if _distance < 4.0:
			# TODO: change this quantity later
			PlayerInventory.add_item(item_name, 1)
			queue_free()
	move_and_slide()


func pick_up_item(player: Player) -> void:
	_player = player
	_being_picked_up = true
