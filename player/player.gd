extends CharacterBody3D

const V_CAMERA_MAX: float = deg_to_rad(80)
const V_CAMERA_MIN: float = deg_to_rad(-80)
const SPEED: float = 7 # ingame meters per second
const MAX_JUMP_VELOCITY: int = 7
const AIM_DISTANCE: float = 200 # used insted of raycasting
const COINS_TEXT: String = "Coins: "
const VALUE_TEXT: String = "Value: "
const MAX_LEVEL_TEXT: String = "MaX LeVeL :)"
const RESPAWN_POSITION: Vector3 = Vector3(0, 5, 0)
const RESPAWN_CAMERA_ROTATION: Vector3 = Vector3(0, 0, 0)
const WORLD_DAMAGE: int = 100
const COTOTE_TIME: float = 0.3

var h_sensitivity: float = 0.25
var v_sensitivity: float = 0.005
var jump_strength: float = 3
var can_increase_jump_strength: bool = true

var max_hp: float = 10.0
var hp: float = 10.0
var damage: int = 1
var firerate: float = 0.25
var durability: int = 1
var bullet_scale: Vector3 = Vector3(1, 1, 1)

@export var bullet_scene: PackedScene
@export var bullet_spawn: Marker3D
@export var player_cam: Camera3D
@export var shooting_timer: Timer
@export var coins_label: Label
@export var effect_animations: AnimationPlayer
@export var gun_shoot_audiostream: AudioStreamPlayer
@export var game_controller: Node3D

@export_group("hp bar")
@export var hp_bar: ProgressBar
@export var hp_text_display: Label

@export_group("shop_ui")
@export var shop_animations: AnimationPlayer

@export_subgroup("Damage Upgrade")
@export var damage_button: Button
@export var damage_cost_label: Label
@export var damage_value_label: Label

@export_subgroup("Firerate Upgrade")
@export var firerate_button: Button
@export var firerate_cost_label: Label
@export var firerate_value_label: Label

@export_subgroup("Health Upgrade")
@export var health_button: Button
@export var health_cost_label: Label
@export var health_value_label: Label

@export_subgroup("Bullet Scale Upgrade")
@export var bullet_scale_button: Button
@export var bullet_scale_cost_label: Label
@export var bullet_scale_value_label: Label

@export_subgroup("Durability Upgrade")
@export var durability_button: Button
@export var durability_cost_label: Label
@export var durability_value_label: Label


func _ready() -> void:
	shooting_timer.wait_time = firerate
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_initial_shop_ui()


func _initial_shop_ui() -> void:
	var shop = Global.SHOP_INFO
	
	# Damage
	var current_damage_value = shop["damage"]["value"]["0"]
	var damage_cost = shop["damage"]["cost"]["1"]
	damage_cost_label.text = COINS_TEXT + str(damage_cost)
	damage_value_label.text = VALUE_TEXT + str(current_damage_value)
	
	# Firerate
	var current_firerate_value = shop["firerate"]["value"]["0"]
	var firerate_cost = shop["firerate"]["cost"]["1"]
	firerate_cost_label.text = COINS_TEXT + str(firerate_cost)
	firerate_value_label.text = VALUE_TEXT + str(current_firerate_value)
	
	# Health
	var current_health_value = shop["health"]["value"]["0"]
	var health_cost = shop["health"]["cost"]["1"]
	health_cost_label.text = COINS_TEXT + str(health_cost)
	health_value_label.text = VALUE_TEXT + str(current_health_value)
	
	# Bullet Scale
	var current_bullet_scale_value = shop["bullet_scale"]["value"]["0"]
	var bullet_scale_cost = shop["bullet_scale"]["cost"]["1"]
	bullet_scale_cost_label.text = COINS_TEXT + str(bullet_scale_cost)
	bullet_scale_value_label.text = VALUE_TEXT + str(current_bullet_scale_value)
	
	# Bullet Durability
	var durability_value = shop["durability"]["value"]["0"]
	var durability_cost = shop["durability"]["cost"]["1"]
	durability_cost_label.text = COINS_TEXT + str(durability_cost)
	durability_value_label.text = VALUE_TEXT + str(durability_value)


func _physics_process(delta: float) -> void:
	if Global.can_spawn_enemies:
		# back and fourth movement
		var input_direction_2D = Input.get_vector(
			"left", "right", "forward", "back"
			)
		var input_direction_3D = Vector3(
			input_direction_2D.x, 0.0, input_direction_2D.y
			)
		var direction = transform.basis * input_direction_3D
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# jumping 
		if Input.is_action_pressed("space") and can_increase_jump_strength:
			velocity.y += jump_strength
		
		if Input.is_action_just_released("space"):
			can_increase_jump_strength = false
		
		if velocity.y >= MAX_JUMP_VELOCITY:
			can_increase_jump_strength = false
	
	if not is_on_floor():
		velocity.y += Global.GRAVITY * delta
	else:
		can_increase_jump_strength = true
	
	move_and_slide()


func _process(_delta: float) -> void:
	if (Input.is_action_pressed("shoot") and 
		shooting_timer.is_stopped() and 
		Global.can_spawn_enemies):
		_shoot_bullet()
	
	coins_label.text = COINS_TEXT + str(Global.coins)
	
	_update_hp()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * h_sensitivity
		player_cam.rotation.x -= event.relative.y * v_sensitivity
		player_cam.rotation.x = clamp(
			player_cam.rotation.x, V_CAMERA_MIN, V_CAMERA_MAX)


func _shoot_bullet() -> void:
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
	gun_shoot_audiostream.play()
	
	# Aim bullet at raycast hit point (or max distance if no hit)
	var target_point = result.position if result else ray_origin + ray_direction * AIM_DISTANCE
	new_bullet.look_at(target_point, Vector3.UP)
	
	shooting_timer.start()


func _on_world_borders_body_entered(body: Node3D) -> void:
	if body == self:
		hp -= WORLD_DAMAGE
		position = RESPAWN_POSITION


func _on_start_fade_body_entered(body: Node3D) -> void:
	if body == self:
		effect_animations.play("fade_in")


func _update_hp() -> void:
	hp_bar.value = hp
	hp_text_display.text = str(hp) + "/" + str(max_hp)
	
	if hp <= 0:
		effect_animations.play("fade_in")
		
		var enemies = get_tree().get_nodes_in_group("enemies")
		for x in enemies:
			x.die()
		
		await effect_animations.animation_finished
		_died()


func _died() -> void:
	position = RESPAWN_POSITION
	player_cam.rotation = RESPAWN_CAMERA_ROTATION
	hp = max_hp
	velocity = Vector3.ZERO
	var enemies = get_tree().get_nodes_in_group("enemies")
	for x in enemies:
		x.queue_free()
	
	Global.can_spawn_enemies = false
	effect_animations.play("fade_out")
	shop_animations.play("open_shop")
	
	Global._unlock_mouse_movement()


# -------------------------------------- Shop functions
func _on_damage_button_pressed() -> void:
	var damage_info = Global.SHOP_INFO["damage"]
	var cost = damage_info["cost"][str(Global.damage_level + 1)]
	if Global.coins < cost:
		return
	
	Global.coins -= cost
	Global.damage_level += 1
	
	var new_value = damage_info["value"][str(Global.damage_level)]
	damage_value_label.text = VALUE_TEXT + str(new_value)
	Global.damage = new_value
	
	var max_level =  damage_info["levels"]
	if Global.damage_level == max_level:
		damage_button.queue_free()
		damage_cost_label.text = MAX_LEVEL_TEXT
	else:
		var new_cost = damage_info["cost"][str(Global.damage_level + 1)]
		damage_cost_label.text = COINS_TEXT + str(new_cost)


func _on_firerate_button_pressed() -> void:
	var firerate_info = Global.SHOP_INFO["firerate"]
	var cost = firerate_info["cost"][str(Global.firerate_level + 1)]
	if Global.coins < cost:
		return
	
	Global.coins -= cost
	Global.firerate_level += 1
	
	var new_value = firerate_info["value"][str(Global.firerate_level)]
	firerate_value_label.text = VALUE_TEXT + str(new_value)
	firerate = new_value
	shooting_timer.wait_time = firerate
	
	var max_level = firerate_info["levels"]
	if Global.firerate_level == max_level:
		firerate_button.queue_free()
		firerate_cost_label.text = MAX_LEVEL_TEXT
	else:
		var new_cost = firerate_info["cost"][str(Global.firerate_level + 1)]
		firerate_cost_label.text = COINS_TEXT + str(new_cost)


func _on_health_button_pressed() -> void:
	var health_info = Global.SHOP_INFO["health"]
	var cost = health_info["cost"][str(Global.hp_level + 1)]
	if Global.coins < cost:
		return
	
	Global.coins -= cost
	Global.hp_level += 1
	
	var new_value = health_info["value"][str(Global.hp_level)]
	health_value_label.text = VALUE_TEXT + str(new_value)
	max_hp = new_value
	hp = max_hp
	
	var max_level = health_info["levels"]
	if Global.hp_level == max_level:
		health_button.queue_free()
		health_cost_label.text = MAX_LEVEL_TEXT
	else:
		var new_cost = health_info["cost"][str(Global.hp_level + 1)]
		health_cost_label.text = COINS_TEXT + str(new_cost)


func _on_bullet_scale_button_pressed() -> void:
	var bullet_scale_info = Global.SHOP_INFO["bullet_scale"]
	var cost = bullet_scale_info["cost"][str(Global.scale_level + 1)]
	if Global.coins < cost:
		return
	
	Global.coins -= cost
	Global.scale_level += 1
	
	var new_value = bullet_scale_info["value"][str(Global.scale_level)]
	bullet_scale_value_label.text = VALUE_TEXT + str(new_value)
	Global.bullet_scale = Vector3(new_value, new_value, new_value)
	
	var max_level = bullet_scale_info["levels"]
	if Global.scale_level == max_level:
		bullet_scale_button.queue_free()
		bullet_scale_cost_label.text = MAX_LEVEL_TEXT
	else:
		var new_cost = bullet_scale_info["cost"][str(Global.scale_level + 1)]
		bullet_scale_cost_label.text = COINS_TEXT + str(new_cost)


func _on_durability_button_pressed() -> void:
	var durability_info = Global.SHOP_INFO["durability"]
	var cost = durability_info["cost"][str(Global.durabilty_level + 1)]
	if Global.coins < cost:
		return
	
	Global.coins -= cost
	Global.durabilty_level += 1
	
	var new_value = durability_info["value"][str(Global.durabilty_level)]
	durability_value_label.text = VALUE_TEXT + str(new_value)
	Global.durability = new_value
	
	var max_level = durability_info["levels"]
	if Global.durabilty_level == max_level:
		durability_button.queue_free()
		durability_cost_label.text = MAX_LEVEL_TEXT
	else:
		var new_cost = durability_info["cost"][str(Global.durabilty_level + 1)]
		durability_cost_label.text = COINS_TEXT + str(new_cost)


func _on_close_button_pressed() -> void:
	shop_animations.play("close_shop")
	set_physics_process(true)
	Global.can_spawn_enemies = true
	Global._lock_mouse_movement()
	game_controller.start_new_run()
