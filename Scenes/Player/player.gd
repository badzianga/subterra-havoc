class_name Player
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction := 0.0

@onready var health_component := $HealthComponent as HealthComponent
@onready var health_bar := $HealthBar  # TODO: move HealthBar to UserInterface
@onready var sprite := $Sprite
@onready var animation_player := $AnimationPlayer
@onready var inventory := $UserInterface/Inventory as Inventory
@onready var looting_component := $LootingComponent as LootingComponent


func _ready() -> void:
	GlobalVariables.player = self
	health_bar.max_value = health_component.max_health


func _physics_process(delta: float) -> void:
	if not inventory.visible:
		_handle_movement(delta)
		_handle_animations()
	
	if Input.is_action_just_pressed("inventory"):
		inventory.initialize_inventory()
		inventory.visible = not inventory.visible
	
	if Input.is_action_pressed("scroll_up"):
		PlayerInventory.active_item_scroll_up()
	if Input.is_action_pressed("scroll_down"):
		PlayerInventory.active_item_scroll_down()
	
	if Input.is_action_just_pressed("pickup"):
		if looting_component.items_in_range.size() > 0:
			var pickup_item: ItemDrop = looting_component.items_in_range.pop_back()
			pickup_item.pick_up_item(self)


func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	_direction = Input.get_axis("left", "right")
	if _direction:
		velocity.x = _direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()


func _handle_animations() -> void:
	 # flips sprite according to walking direction
	if _direction > 0:
		sprite.flip_h = true
	elif _direction < 0:
		sprite.flip_h = false
	
	# animation for falling and jumping
	if not is_on_floor():
		if velocity.y > 0.0:
			animation_player.play("fall")
		else:
			animation_player.play("jump")
	# move and idle animations
	elif _direction:
		animation_player.play("run")
	else:
		animation_player.play("idle")


func _on_health_component_health_changed() -> void:
	health_bar.value = health_component.health


func _on_health_component_health_depleted() -> void:
	set_physics_process(false)
