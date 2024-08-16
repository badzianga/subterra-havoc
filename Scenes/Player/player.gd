# TODO: player health is not saved between scenes - switching scenes makes new
# player object with default health
# FIXME: physics interpolation makes camera rotation very fast, possible solutions:
# - change camera rotation smoothing from 8 to 4 (check speed on Max's PC)
# - use own rotation smoothing (tests needed)

class_name Player
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const CUT_JUMP_HEIGHT := 0.4
const DASH_MULTIPLIER := 2.5
const AIR_RESISTANCE := 10.0

var _gravity_value := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var _current_rotation := 0.0
var _direction := 0.0
# HACK: movement, jumping and gravity works with this, at the end of the frame this vector
# is rotated so it corresponds to current camera rotation
var _velocity: Vector2

var _can_dash := true
var _is_dashing := false
var _dash_direction := 0.0
var _previous_velocity: Vector2  # used by air resistance

@onready var health_component := $HealthComponent as HealthComponent
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
@onready var _hitbox_component := $HitboxComponent as HitboxComponent
@onready var _interaction_component := $InteractionComponent as InteractionComponent

var is_attacking := false


func _ready() -> void:
	GlobalVariables.player = self
	
	if not SaveSystem.loaded_data.is_empty():
		health_component.max_health = SaveSystem.loaded_data["PlayerMaxHealth"]
		health_component.health = SaveSystem.loaded_data["PlayerHealth"]
		SaveSystem.loaded_data.erase("PlayerMaxHealth")
		SaveSystem.loaded_data.erase("PlayerHealth")
	
	_health_bar.max_value = health_component.max_health
	_health_bar.value = health_component.health


# temporary
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_left"):
		var _tween := create_tween()
		_tween.tween_property(self, "rotation_degrees", rotation_degrees + 90.0, 0.05)
		_current_rotation -= PI / 2
		up_direction = Vector2.UP.rotated(-_current_rotation)
		# TODO: GDD says that speed should be conserved, so test if this makes game better
		velocity = Vector2.ZERO  # prevents velocity.x from changing into gravity
	elif event.is_action_pressed("rotate_right"):
		var _tween := create_tween()
		_tween.tween_property(self, "rotation_degrees", rotation_degrees - 90.0, 0.05)
		_current_rotation += PI / 2
		up_direction = Vector2.UP.rotated(-_current_rotation)
		# TODO: GDD says that speed should be conserved, so test if this makes game better
		velocity = Vector2.ZERO  # prevents velocity.x from changing into gravity


func _physics_process(delta: float) -> void:
	if not inventory.visible:
		_handle_movement(delta)
		_handle_animations()
		_handle_attacking()
	
	_handle_inventory_inputs()
	
	if Input.is_action_just_pressed("pickup"):
		# first check if can pick item; if not, then check if can interact with object
		if _looting_component.items_in_range.size() > 0:
			var _pickup_item: ItemDrop = _looting_component.items_in_range.pop_back()
			_pickup_item.pick_up_item()
		elif _interaction_component.interactable != null:
			_interaction_component.interactable.interact()


func _handle_movement(delta: float) -> void:
	_velocity = velocity.rotated(_current_rotation)
	
	# apply gravity
	if not is_on_floor() and not _is_dashing:
		_velocity.y += _gravity_value * delta

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_velocity.y = JUMP_VELOCITY
	# variable jump height
	if Input.is_action_just_released("jump"):
		if _velocity.y < 0.0:
			_velocity.y *= CUT_JUMP_HEIGHT
	
	_direction = Input.get_axis("left", "right")
	
	_check_dashing()
	
	# dash to the same direction even if player releases left/right 
	if _is_dashing:
		_velocity.x = _dash_direction * DASH_MULTIPLIER * SPEED
	# normal movement 
	elif _direction:
		_velocity.x = _direction * SPEED
	# slowing down
	else:
		# TODO: multiplying SPEED by fraction gives slowing down instead of immediate stopping
		# do that if we implement accelerating
		_velocity.x = move_toward(_velocity.x, 0.0, SPEED)
	
	 # air resistance
	if not is_on_floor() and not _is_dashing:
		_velocity.x = lerp(_previous_velocity.x, _velocity.x, AIR_RESISTANCE * delta)
	
	velocity = _velocity.rotated(-_current_rotation)
	move_and_slide()
	
	# also used in air resistance
	_velocity = velocity.rotated(_current_rotation)
	_previous_velocity.x = _velocity.x


func _handle_animations() -> void:
	 # flips sprite according to walking direction
	if _direction > 0.0:
		_sprite.flip_h = false
		# TODO: rotating hitbox every frame is not the best option for performance
		_hitbox_component.rotation = 0
	elif _direction < 0.0:
		_sprite.flip_h = true
		_hitbox_component.rotation = PI
	
	# animation for falling and jumping
	if is_attacking:
		return
	if not is_on_floor():
		if _velocity.y > 0.0:
			_animation_player.play("fall")
		else:
			_animation_player.play("jump")
	# move and idle animations
	elif _direction:
		_animation_player.play("run")
	else:
		_animation_player.play("idle")


func _handle_attacking() -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		_animation_player.play("dagger_" + str(randi_range(1, 3)))
		await _animation_player.animation_finished
		is_attacking = false


func _handle_inventory_inputs() -> void:
	if Input.is_action_just_pressed("inventory"):
		inventory.visible = not inventory.visible
		# initialize inventory only when opening it
		if inventory.visible:
			inventory.initialize_inventory()
		# check if user tries to leave inventory while holding item
		else:
			inventory.safely_close()
		
	
	if Input.is_action_pressed("scroll_up"):
		PlayerInventory.active_item_scroll_up()
	if Input.is_action_pressed("scroll_down"):
		PlayerInventory.active_item_scroll_down()


func _check_dashing() -> void:
	if not Input.is_action_just_pressed("dash"):
		return
	if _direction == 0.0:
		return
	if _can_dash and _dash_cooldown.is_stopped():
		_can_dash = false
		_is_dashing = true
		_dash_direction = _direction
		_hurtbox_collider.set_deferred("disabled", true)
		_dashing_timer.start()
		# dashing while jumping makes player jump higher, multiplying velocity.y reduces this height
		velocity.y *= 0.3


func _on_health_component_health_changed() -> void:
	var _tween := create_tween()
	_tween.tween_property(_health_bar, "value", health_component.health, 0.8)
	_tween.set_trans(Tween.TRANS_LINEAR)
	#_health_bar.value = health_component.health
	_immunity_frames_timer.start()
	# TODO: try to use tween here instead of animation player
	_blinking_animation.play("blinking")


func _on_health_component_health_depleted() -> void:
	SaveSystem.delete_run_save()
	# TODO: better would be calling special method, I don't want to hold scene
	# path in player's script
	# TODO: inventory is not cleared - there should be another method which
	# will clear other global variables than nodes. Also, there should be a some
	# sort of death screen 
	MapSwitch.call_deferred("change_map", "res://Scenes/Maps/village.tscn")


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
