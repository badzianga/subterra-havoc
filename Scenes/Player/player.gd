# TODO: player health is not saved between scenes - switching scenes makes new
# player object with default health
# FIXME: physics interpolation makes camera rotation very fast, possible solutions:
# - change camera rotation smoothing from 8 to 4 (check speed on Max's PC)
# - use own rotation smoothing (tests needed)
# TODO: handling weapon will be pretty complex - do WeaponController in the future

class_name Player
extends CharacterBody2D

const DashGhostScene := preload("res://Scenes/Player/dash_ghost.tscn")
const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const CUT_JUMP_HEIGHT := 0.4
const DASH_MULTIPLIER := 2.0
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
var _is_attacking := false
var _weapon: Weapon

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
@onready var _dash_ghost_timer := $DashGhostTimer
@onready var _combo_timer := $ComboTimer


func _ready() -> void:
	GlobalVariables.player = self
	
	if not SaveSystem.loaded_data.is_empty():
		health_component.max_health = SaveSystem.loaded_data["PlayerMaxHealth"]
		health_component.health = SaveSystem.loaded_data["PlayerHealth"]
		SaveSystem.loaded_data.erase("PlayerMaxHealth")
		SaveSystem.loaded_data.erase("PlayerHealth")
	
	_health_bar.max_value = health_component.max_health
	_health_bar.value = health_component.health
	
	PlayerInventory.active_item_updated.connect(_on_active_item_updated)
	
	# TODO: temporary I think
	_weapon = PlayerInventory.get_weapon_from_active_slot()


# temporary
# FIXME: setting Engine.time_scale to 0.1 and triggering rotate in oposite direction while still
# rotating halts previous rotation on weird angle and rotates this weird angle by 90 degrees, so
# final rotation is wrong.
# This might be fixed in with doing auto rotation, however tests are required.
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
	if _is_attacking:
		return
	if _is_dashing:
		_animation_player.play("dash")
	elif not is_on_floor():
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
	if _weapon == null:
		return
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		_combo_timer.stop()
		Logger.debug("Attack combo: %d" % _weapon.current_combo)
		_is_attacking = true
		_animation_player.play(_weapon.type + str(_weapon.current_combo))
		# TODO: magic number - change in future
		_combo_timer.wait_time = _animation_player.current_animation_length as float + 0.3
		_combo_timer.start()
		Logger.debug("Started timer with time: %.3fs" % _combo_timer.wait_time)
		await _animation_player.animation_finished
		_weapon.current_combo = (_weapon.current_combo + 1) % _weapon.combo
		_is_attacking = false


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
	# start dash
	if _can_dash and _dash_cooldown.is_stopped():
		_instance_dash_ghost()
		_can_dash = false
		_is_dashing = true
		_dash_direction = _direction
		_hurtbox_collider.set_deferred("disabled", true)
		_dashing_timer.start()
		_dash_ghost_timer.start()
		# dashing while jumping makes player jump higher, multiplying velocity.y reduces this height
		velocity.y *= 0.3


func _instance_dash_ghost() -> void:
	var _ghost := DashGhostScene.instantiate()
	_ghost.global_position = global_position
	_ghost.global_rotation = global_rotation
	_ghost.flip_h = _sprite.flip_h
	GlobalVariables.map_node.add_child(_ghost)


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
	_dash_ghost_timer.stop()
	_dash_cooldown.start()


func _on_immunity_frames_timer_timeout() -> void:
	_hurtbox_collider.set_deferred("disabled", false)
	_blinking_animation.stop()


func _on_dash_ghost_timer_timeout() -> void:
	_instance_dash_ghost()


func _on_active_item_updated() -> void:
	_weapon = null
	_weapon = PlayerInventory.get_weapon_from_active_slot()


func _on_combo_timer_timeout() -> void:
	Logger.debug("Combo ended")
	_weapon.current_combo = 0
