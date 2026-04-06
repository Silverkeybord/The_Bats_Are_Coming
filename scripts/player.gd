extends CharacterBody3D

const V_CAMERA_MAX := deg_to_rad(88)
const V_CAMERA_MIN := deg_to_rad(-88)

const SPEED := 7.5
const ACCELERATION := 40.0
const DECELERATION := 30.0
const INITIAL_JUMP_VELOCITY := 7.0
const JUMP_HOLD_ACCELERATION := 40.0
const MAX_JUMP_VELOCITY := 8.5
const COYOTE_TIME := 0.15

const ARROW = " > "
const COINS_TEXT := "Coins: "
const VALUE_TEXT := "Value: "
const WAVE_VISUAL_TEXT := "Wave "
const FPS_TEXT := "FPS: "

const LOAD_BUFFER := 0.5

const WHITE_FPS := Color(1.0, 1.0, 1.0, 1.0)
const YELLOW_FPS := Color(1.0, 1.0, 0.451, 1.0)
const ORANGE_FPS := Color(1.0, 0.647, 0.0, 1.0)
const RED_FPS := Color(1.0, 0.49, 0.451)

const WHITE_THRESHOLD := 50
const YELLOW_THRESHOLD := 40
const ORANGE_THRESHOLD := 20
const RED_THRESHOLD := 10

const RESPAWN_POSITION := Vector3(0, 5, 0)
const RESPAWN_CAMERA_ROTATION := Vector3(0, 0, 0)
const PATH_OPEN_SPAWN_POSITION := Vector3(176, 26, 0)

const AIM_DISTANCE := 200
const WORLD_DAMAGE := 0.5 # percentage of damage interms of max hp
const HURT_THRESHOLD := 1.4 # the amount hp is divided by before showing

const OUT_OF_THIS_WORLD_DISTANCE := 65.0 # meters away fom 0, 0, 0
const OUT_OF_THIS_WORLD_REWARD := 100
const MOBS_ALIVE_VL_THRESHOLD:= 30

const BOSS_WAVE_TEXT := "Boss :o"
const NO_SELECTED_WAVE := 25

const VL_FIRST_DEATH_KEY := "first_death"
const VL_DEATH_KEY := "death"
const VL_MAX_SCALE_KEY := "max_out_scale"
const VL_FIRST_UPGRADE_KEY := "first_upgrade"
const VL_10K_COINS_KEY := "ten_k_coins"
const VL_OUT_OF_THIS_WORLD_KEY := "out_of_this_world"
const VL_MORE_THAN_30_BATS_KEY := "more_than_30_bats"

var h_sensitivity := 6
var v_sensitivity := 0.15
var can_increase_jump_strength := true
var holding_jump := false
var initial_jump_done := false

var coyote_timer := 0.0
var current_speed := 0.0
var max_hp := 10.0
var hp := 0.0
var damage := 1
var firerate := 0.25
var pierce := 1
var bullet_scale := Vector3(1, 1, 1)

var can_more_than_30_bats := false

@export_group("in scene exports")
@export var bullet_scene: PackedScene
@export var bullet_spawn: Marker3D
@export var player_cam: Camera3D
@export var shooting_timer: Timer
@export var coins_label: Label
@export var effect_animations: AnimationPlayer
@export var hurt_image: TextureRect
@export var boss_button: Button
@export var FPS_lable: Label

@export_group("out of scene exports")
@export var game_controller: Node3D

@export_group("hp bar")
@export var hp_bar: ProgressBar
@export var hp_text_display: Label

@export_group("shop_ui")
@export var shop_animations: AnimationPlayer

@export_subgroup("Upgrades")
@export var damage_upgrade: PanelContainer
@export var hp_upgrade: PanelContainer
@export var firerate_upgrade: PanelContainer
@export var scale_upgrade: PanelContainer
@export var pierce_upgrade: PanelContainer

@export_group("Wave Selection")
@export var wave_buttons: Node
@export var wave_label: Label


func _ready() -> void:
	hp = max_hp
	shooting_timer.wait_time = firerate
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	await get_tree().create_timer(LOAD_BUFFER).timeout
	_check_wave_selection_unlocks()


func _physics_process(delta: float) -> void:
	if not Global.lock_movement:
		var input_direction = Input.get_vector("left", "right", "forward", "back")
		var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()

		if input_direction != Vector2.ZERO:
			velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION * delta)
			velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
			velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)
		
		# -- jumping -- 
		# longer you hold the higher you will jump after the initial boost of
		# jumping, there is also the coyote time using delta subtraction
		if Input.is_action_pressed("space") and can_increase_jump_strength:
			if not initial_jump_done:
				velocity.y = INITIAL_JUMP_VELOCITY
				initial_jump_done = true
				holding_jump = true
			else:
				velocity.y += JUMP_HOLD_ACCELERATION * delta
		
		
		if Input.is_action_just_released("space"):
			can_increase_jump_strength = false
			holding_jump = false
		
		
		if velocity.y >= MAX_JUMP_VELOCITY:
			can_increase_jump_strength = false
	
	
	if not is_on_floor():
		velocity.y += Global.GRAVITY * delta
		coyote_timer -= delta
		
		if not holding_jump and coyote_timer <= 0:
			can_increase_jump_strength = false
	else:
		coyote_timer = COYOTE_TIME
		initial_jump_done = false
		can_increase_jump_strength = true
	
	move_and_slide()


func _process(delta: float) -> void:
	if (Input.is_action_pressed("shoot") and 
		shooting_timer.is_stopped() and
		not Global.lock_movement):
		_shoot_bullet()
	
	if Input.is_action_just_pressed("die") and not Global.lock_movement:
		hp = 0
		_update_hp()
	
	if Input.is_action_just_pressed("ui_text_select_all"):
		Global.highest_wave = 26
	
	coins_label.text = COINS_TEXT + str(Global.coins)
	
	hurt_image.modulate.a = clamp(1.0 - (hp / max_hp) * HURT_THRESHOLD, 0.0, 1.0)
	
	_update_hp()
	
	var FPS = round(1/delta * 10) / 10
	if FPS > WHITE_THRESHOLD:
		FPS_lable.modulate = WHITE_FPS
	elif FPS > YELLOW_THRESHOLD:
		FPS_lable.modulate = YELLOW_FPS
	elif FPS > ORANGE_THRESHOLD:
		FPS_lable.modulate = ORANGE_FPS
	elif FPS > RED_THRESHOLD:
		FPS_lable.modulate = RED_FPS
	
	FPS_lable.text = FPS_TEXT + str(FPS)
	
	# voic lines stuff
	if (Global.coins >= 10000 and 
		not Global.single_activation_vls[VL_10K_COINS_KEY]):
		
		VoiceLines.play_vl(VL_10K_COINS_KEY)
	
	if Global.mobs_left >= MOBS_ALIVE_VL_THRESHOLD and can_more_than_30_bats:
		can_more_than_30_bats = true
		VoiceLines.play_vl(VL_MORE_THAN_30_BATS_KEY)
	
	else:
		can_more_than_30_bats = false
	
	if (position.x >= OUT_OF_THIS_WORLD_DISTANCE or 
		position.x <= -OUT_OF_THIS_WORLD_DISTANCE or
		position.z >= OUT_OF_THIS_WORLD_DISTANCE or
		position.z <= -OUT_OF_THIS_WORLD_DISTANCE
		):
		
		if (not Global.single_activation_vls[VL_OUT_OF_THIS_WORLD_KEY] and 
			not Global.path_open):
			
			VoiceLines.play_vl(VL_OUT_OF_THIS_WORLD_KEY)
			Global.coins += OUT_OF_THIS_WORLD_REWARD


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not Global.lock_movement:
		rotation_degrees.y -= deg_to_rad(event.relative.x * h_sensitivity)
		player_cam.rotation.x -= deg_to_rad(event.relative.y * v_sensitivity)
		player_cam.rotation.x = clamp(
			player_cam.rotation.x, V_CAMERA_MIN, V_CAMERA_MAX)


func _shoot_bullet() -> void:
	print(Global.shop_upgrades)
	
	# Get the center of the screen (where the reticle is)
	var viewport_center = get_viewport().get_visible_rect().size / 2
	
	# Convert 2D screen position to 3D ray
	var ray_origin = player_cam.project_ray_origin(viewport_center)
	var ray_direction = player_cam.project_ray_normal(viewport_center)
	
	# Setup physics raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_direction * AIM_DISTANCE
	)
	
	# Perform the raycast
	var result = space_state.intersect_ray(query)
	
	# Spawn bullet
	var new_bullet = bullet_scene.instantiate()
	add_sibling(new_bullet)  # Adds as sibling to player
	new_bullet.global_position = bullet_spawn.global_position

	# Aim bullet at raycast hit point (or max distance if no hit)
	var target_point = result.position if result else ray_origin + ray_direction * AIM_DISTANCE
	new_bullet.look_at(target_point, Vector3.UP)
	
	shooting_timer.start()


func _on_world_borders_body_entered(body: Node3D) -> void:
	if body == self and not Global.player_died:
		hp -= max_hp * WORLD_DAMAGE
		position = RESPAWN_POSITION
		velocity = Vector3.ZERO


func _on_start_fade_body_entered(body: Node3D) -> void:
	if body == self and hp <= max_hp * WORLD_DAMAGE:
		effect_animations.play("fade_in")


func _update_hp() -> void:
	hp_bar.value = hp
	hp_text_display.text = str(hp) + "/" + str(max_hp)
	
	if hp <= 0 and not Global.player_died:
		Global.clear_items_and_mobs()
		
		effect_animations.play("fade_in")
		
		_died()


func _died() -> void:
	Global.player_died = true
	Global.fighting_boss = false
	Global.can_spawn_enemies = false
	Global.save_game()
	
	await effect_animations.animation_finished
	
	if Global.player_died:
		if not Global.single_activation_vls[VL_FIRST_DEATH_KEY]:
			await VoiceLines.play_vl(VL_FIRST_DEATH_KEY)
		else:
			await VoiceLines.play_vl(VL_DEATH_KEY)
	
	player_cam.rotation = RESPAWN_CAMERA_ROTATION
	hp = max_hp
	velocity = Vector3.ZERO
	
	Global._unlock_mouse_movement()
	_check_wave_selection_unlocks()
	game_controller.reset_wave_display()
	Global.current_wave = Global.selected_wave
	
	# if the path is open give the option to go straight to the boss or do more waves
	if Global.path_open:
		effect_animations.play("show_retry")
		return
	else: 
		position = RESPAWN_POSITION
	
	Global.shop_open = true
	
	effect_animations.play("fade_out")
	shop_animations.play("open_shop")
	
	await shop_animations.animation_finished
	
	Global._unlock_mouse_movement()


func _on_close_button_pressed() -> void:
	_update_stats()
	shop_animations.play("close_shop")
	set_physics_process(true)
	Global.shop_open = false
	Global._lock_mouse_movement()
	game_controller.start_new_run()


func _update_stats() -> void:
	Global.damage = Global.SHOP_INFO["damage"]["value"][str(Global.shop_upgrades["damage"])]
	max_hp = Global.SHOP_INFO["health"]["value"][str(Global.shop_upgrades["health"])]
	hp = max_hp
	hp_bar.max_value = max_hp
	firerate = Global.SHOP_INFO["firerate"]["value"][str(Global.shop_upgrades["firerate"])]
	shooting_timer.wait_time = firerate
	var Bscale = Global.SHOP_INFO["bullet_scale"]["value"][str(Global.shop_upgrades["bullet_scale"])]
	Global.bullet_scale = Vector3(Bscale, Bscale, Bscale)
	Global.pierce = Global.SHOP_INFO["pierce"]["value"][str(Global.shop_upgrades["pierce"])]


# --------------------------- wave selection funcions
func _check_wave_selection_unlocks() -> void:
	var unlocked_selectable_waves := 0
	var buttons: Array = wave_buttons.find_children("" ,"Button")
	print(buttons)
	unlocked_selectable_waves = floor(Global.highest_wave / 5.0) + 1
	
	for x in buttons:
		if unlocked_selectable_waves > 0:
			x.disabled = false
			unlocked_selectable_waves -= 1
	
	if Global.highest_wave == Global.BOSS_WAVE:
		boss_button.visible = true
		boss_button.disabled = false


func _on_wave_1_pressed() -> void:
	Global.selected_wave = 1
	wave_label.text = WAVE_VISUAL_TEXT + str(Global.selected_wave)


func _on_wave_5_pressed() -> void:
	Global.selected_wave = 5
	wave_label.text = WAVE_VISUAL_TEXT + str(Global.selected_wave)


func _on_wave_10_pressed() -> void:
	Global.selected_wave = 10
	wave_label.text = WAVE_VISUAL_TEXT + str(Global.selected_wave)


func _on_wave_15_pressed() -> void:
	Global.selected_wave = 15
	wave_label.text = WAVE_VISUAL_TEXT + str(Global.selected_wave)


func _on_wave_20_pressed() -> void:
	Global.selected_wave = 20
	wave_label.text = WAVE_VISUAL_TEXT + str(Global.selected_wave)


func _on_wave_25_pressed() -> void:
	Global.selected_wave = 25
	wave_label.text = WAVE_VISUAL_TEXT + str(Global.selected_wave)


func _on_boss_pressed() -> void:
	Global.selected_wave = Global.BOSS_WAVE
	wave_label.text = BOSS_WAVE_TEXT


# boss retrying
func _on_yes_pressed() -> void:
	Global.player_died = false
	position = PATH_OPEN_SPAWN_POSITION
	
	effect_animations.play("hide_retry")
	await effect_animations.animation_finished
	
	effect_animations.play("fade_out")
	
	Global._lock_mouse_movement()


func _on_no_pressed() -> void:
	position = RESPAWN_POSITION
	
	Global.shop_open = true
	Global.path_open = false
	Global.can_spawn_enemies = false
	Global.selected_wave = NO_SELECTED_WAVE
	
	game_controller.boss_related_animations.play("close_path")
	
	effect_animations.play("hide_retry")
	await effect_animations.animation_finished
	
	effect_animations.play("fade_out")
	shop_animations.play("open_shop")
	
	await shop_animations.animation_finished
	
	Global._unlock_mouse_movement()
