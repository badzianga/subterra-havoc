class_name Player
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction := Vector2.ZERO

@onready var _health_component := $HealthComponent as HealthComponent
@onready var _health_bar := $UserInterface/HealthBar
@onready var _sprite := $Sprite
@onready var _animation_player := $AnimationPlayer
@onready var _inventory := $UserInterface/Inventory as Inventory
@onready var _looting_component := $LootingComponent as LootingComponent


func _ready() -> void:
	GlobalVariables.player = self
	_health_bar.max_value = _health_component.max_health
	_health_bar.value = _health_component.health


func _physics_process(delta: float) -> void:
	if not _inventory.visible:
		_handle_movement(delta)
		_handle_animations()
	
	if Input.is_action_just_pressed("inventory"):
		_inventory.initialize_inventory()
		_inventory.visible = not _inventory.visible
	
	if Input.is_action_pressed("scroll_up"):
		PlayerInventory.active_item_scroll_up()
	if Input.is_action_pressed("scroll_down"):
		PlayerInventory.active_item_scroll_down()
	
	if Input.is_action_just_pressed("pickup"):
		if _looting_component.items_in_range.size() > 0:
			var _pickup_item: ItemDrop = _looting_component.items_in_range.pop_back()
			_pickup_item.pick_up_item(self)


func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravity * delta

	if Input.is_action_just_pressed("jump") and velocity.y < 0.0:
		velocity.y = JUMP_VELOCITY * 0.25

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	_direction.x = Input.get_axis("left", "right")
	if _direction.x:
		velocity.x = _direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()


func _handle_animations() -> void:
	 # flips sprite according to walking direction
	if _direction.x > 0.0:
		_sprite.flip_h = true
	elif _direction.x < 0.0:
		_sprite.flip_h = false
	
	# animation for falling and jumping
	if not is_on_floor():
		if velocity.y > 0.0:
			_animation_player.play("fall")
		else:
			_animation_player.play("jump")
	# move and idle animations
	elif _direction:
		_animation_player.play("run")
	else:
		_animation_player.play("idle")


func _on_health_component_health_changed() -> void:
	_health_bar.value = _health_component.health
	# TODO: animate reducing hp instead of removing it immediately


func _on_health_component_health_depleted() -> void:
	set_physics_process(false)
