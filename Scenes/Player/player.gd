class_name Player
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const CUT_JUMP_HEIGHT := 0.4
const DASH_MULTIPLIER := 2.5

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction := Vector2.ZERO

var _can_dash := true
var _is_dashing := false

@onready var _health_component := $HealthComponent as HealthComponent
@onready var _health_bar := $UserInterface/HealthBar
@onready var _sprite := $Sprite
@onready var _animation_player := $AnimationPlayer
@onready var inventory := $UserInterface/Inventory as Inventory
@onready var _looting_component := $LootingComponent as LootingComponent
@onready var _dash_cooldown := $DashCooldown
@onready var _dashing_timer := $DashingTimer
@onready var _hurtbox_collider := $HurtboxComponent/CollisionShape
@onready var _immunity_frames_timer := $ImmunityFramesTimer
@onready var _blinking_animation := $ImmunityFramesTimer/BlinkingAnimation


func _ready() -> void:
	GlobalVariables.player = self
	_health_bar.max_value = _health_component.max_health
	_health_bar.value = _health_component.health


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
		if _looting_component.items_in_range.size() > 0:
			var _pickup_item: ItemDrop = _looting_component.items_in_range.pop_back()
			_pickup_item.pick_up_item(self)


func _handle_movement(delta: float) -> void:
	# apply gravity
	if not is_on_floor() and not _is_dashing:
		velocity.y += _gravity * delta

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# variable jump height
	if Input.is_action_just_released("jump"):
		if velocity.y < 0.0:
			velocity.y *= CUT_JUMP_HEIGHT
	
	# start dashing
	if Input.is_action_just_pressed("dash") and _can_dash and _dash_cooldown.is_stopped():
		_can_dash = false
		_is_dashing = true
		_hurtbox_collider.set_deferred("disabled", true)
		_dashing_timer.start()

	# move left/right
	_direction.x = Input.get_axis("left", "right")
	if _direction.x:
		if _is_dashing:
			velocity.x = _direction.x * DASH_MULTIPLIER * SPEED
		else:
			velocity.x = _direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
	
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
	_immunity_frames_timer.start()
	_blinking_animation.play("blinking")
	# TODO: animate reducing hp instead of removing it immediately


func _on_health_component_health_depleted() -> void:
	set_physics_process(false)


func _on_dash_cooldown_timeout() -> void:
	_can_dash = true


func _on_dashing_timer_timeout() -> void:
	# enable collider only when immunity frames aren't active
	# (so invincibility won't be shortened by dash)
	if _immunity_frames_timer.is_stopped():
		_hurtbox_collider.set_deferred("disabled", false)
	_is_dashing = false
	_dash_cooldown.start()


func _on_immunity_frames_timer_timeout() -> void:
	_hurtbox_collider.set_deferred("disabled", false)
	_blinking_animation.stop()
