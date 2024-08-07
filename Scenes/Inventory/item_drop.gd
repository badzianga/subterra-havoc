# World item class, which can be picked up by the player.
# TODO: maybe add item quantity variable?

class_name ItemDrop
extends CharacterBody2D

const ACCELERATION := 920.0
const MAX_SPEED := 450.0
const COLLECT_RADIUS := 4.0

var _item_id := "oreGold"  # temporary id
var _being_picked_up := false


# Updates item's position in the world.
func _physics_process(delta: float) -> void:
	# if not picked - move item towards ground
	if not _being_picked_up:
		velocity = velocity.move_toward(Vector2(0, MAX_SPEED), ACCELERATION * delta)
	# if picked - move item towards player
	else:
		var _direction := global_position.direction_to(GlobalVariables.player.global_position)
		velocity = velocity.move_toward(_direction * MAX_SPEED, ACCELERATION * delta)
		
		# collect item if close enough to the player
		var _distance := global_position.distance_to(GlobalVariables.player.global_position)
		if _distance < COLLECT_RADIUS:
			# TODO: change this quantity later
			PlayerInventory.collect_item(_item_id, 1)
			queue_free()
	move_and_slide()


# Sets item id and texture. Called by item_drop_component.
func initialize_item(item_id: String) -> void:
	_item_id = item_id
	var _file_name := ItemData.item_data[_item_id]["FileName"] as String
	$Sprite.texture = load("res://Assets/Items/" + _file_name)


# Sets _being_picked_up variable to true, so Called by player.
func pick_up_item() -> void:
	_being_picked_up = true
