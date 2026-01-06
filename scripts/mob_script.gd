extends RigidBody3D

const RAGDOLL_TIME := 4
const MIN_RANDOM_VECTOR3_VALUE := 5
const MAX_RANDOM_VECTOR3_VALUE := 10
const VERTICLE_SPEED := 3
const RANDOM_FLYING_HEIGHT_OFFSET := 0.2
const RANDOM_SPEED := 0.5
const HALF_PLAYER_HEIGHT := 1.25

# bat types
const FAST_TYPE_KEY := "fast"
const HEAVY_TYPE_KEY := "heavy"
const SKY_TYPE_KEY := "sky"
const SHOOTER_TYPE_KEY := "shooter"
const TRANSPARENT_TYPE_KEY := "transparent"

# sky bat area properties
const SKY_ATTACK_AREA_RADIUS := 4.0
const SKY_MOVE_AREA_RADIUS := 2.0
const SKY_BAT_Y_PROJECTILE_OFFSET := 0.3
const RANDOM_XZ_OFFSET := 1.0 # +- 1 meter along x and z axix

# shooter bat area properties
const SHOOTER_ATTACK_AREA_RADIUS := 8
const SHOOTER_MOVE_AREA_RADIUS := 7

# if bats go here they get teleported to glitch position
const LOWEST_POINT := -5

# pick random sound to play when attacking
const ATTACK_SOUNDS := [
	preload("res://sounds/SFX/mob_attack_sounds/punch-gaming-sound-effect-hd_RzlG1GE.mp3"),
	preload("res://sounds/SFX/mob_attack_sounds/punch-notification_sound-493565.mp3"),
	preload("res://sounds/SFX/mob_attack_sounds/punch-sound-effect-meme.mp3"),
	preload("res://sounds/SFX/mob_attack_sounds/punch_u4LmMsr.mp3"),
	preload("res://sounds/SFX/mob_attack_sounds/weak-punch.mp3")
]

# bat stats and information
var in_attack_range := false
var can_move := true
var can_attack := true
var flying_height: float
var damage: int
var hp: int
var value: int
var speed: float
var attack_interval: float
var bat_texture: Texture

# used to make the bat fly the correct distance above the ground
var too_high := true
var too_low := false
var should_rise := false

@export_group("in scene exports")
@export var bat_model: Node3D
@export var attack_timer: Timer
@export var height_check_areas: Node3D
@export var bat_mesh: MeshInstance3D

@export_subgroup("animation players")
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer

@export_subgroup("collision_shapes")
@export var rigid_body_collisionshape: CollisionShape3D
@export var attack_collisionshape: CollisionShape3D
@export var move_collisionshape: CollisionShape3D

@export_subgroup("shooter bat")
@export var shooter_projectile_spawn: Marker3D

@export_subgroup("transparent bat time's")
@export var transparent_interval: Timer
@export var transparent_duration: Timer

@export_group("out of scene exports")
@export var sky_bat_projectile: PackedScene
@export var shooter_bat_projectile: PackedScene
@export var player: CharacterBody3D
@export var game_controller: Node3D

@export_group("sounds")
@export var death_sound: AudioStreamPlayer3D
@export var hurt_sound: AudioStreamPlayer3D
@export var attack_sound: AudioStreamPlayer3D

@export_group("stats")
@export var type: String

@onready var bat_mat: StandardMaterial3D


func _ready() -> void:
	var bat_info = Global.ENEMY_INFO[type]
	
	value = round(bat_info["value"] * Global.base_stat_mult)
	damage = round(bat_info["damage"] * Global.base_stat_mult)
	hp = round(bat_info["health"] * Global.base_stat_mult)
	
	speed = bat_info["speed"]
	speed += randf_range(-RANDOM_SPEED, RANDOM_SPEED)
	
	flying_height = bat_info["flight_height"] 
	flying_height += randf_range(-RANDOM_FLYING_HEIGHT_OFFSET,
		 RANDOM_FLYING_HEIGHT_OFFSET)
	
	attack_interval = bat_info["attack_interval"]
	
	var base_mat := bat_mesh.get_active_material(0)
	if base_mat:
		bat_mat = base_mat.duplicate()
		bat_mesh.set_surface_override_material(0, bat_mat)
		bat_mat.albedo_texture = bat_info["texture"]
	
	if type == HEAVY_TYPE_KEY or type == FAST_TYPE_KEY:
		bat_model.scale = Global.ENEMY_INFO[type]["scale"]
		rigid_body_collisionshape.scale = Global.ENEMY_INFO[type]["scale"]
		
	elif type == TRANSPARENT_TYPE_KEY:
		bat_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		transparent_interval.wait_time = bat_info["invisible_interval"]
		transparent_duration.wait_time = bat_info["invisible_duration"]
		transparent_interval.start()
	
	elif type == SKY_TYPE_KEY:
		# height is multiplyd by 2 because of the round ends of the capsul 
		attack_collisionshape.shape = CapsuleShape3D.new()
		attack_collisionshape.shape.radius = SKY_ATTACK_AREA_RADIUS
		attack_collisionshape.shape.height = flying_height + SKY_ATTACK_AREA_RADIUS * 2
		attack_collisionshape.position.y = -(
			attack_collisionshape.shape.height / 2 - SKY_ATTACK_AREA_RADIUS)
		
		move_collisionshape.shape = CapsuleShape3D.new()
		move_collisionshape.shape.radius = SKY_MOVE_AREA_RADIUS
		move_collisionshape.shape.height = flying_height + SKY_MOVE_AREA_RADIUS * 2
		move_collisionshape.position.y = -(
			move_collisionshape.shape.height / 2 - SKY_MOVE_AREA_RADIUS)
	
	elif type == SHOOTER_TYPE_KEY:
		attack_collisionshape.shape = attack_collisionshape.shape.duplicate()
		attack_collisionshape.shape.radius = SHOOTER_ATTACK_AREA_RADIUS
		move_collisionshape.shape = move_collisionshape.shape.duplicate()
		move_collisionshape.shape.radius = SHOOTER_MOVE_AREA_RADIUS
	
	height_check_areas.position.y = -flying_height 


func _physics_process(delta: float) -> void:
	var target_pos := Vector3(
	player.global_position.x,
	global_position.y,
	player.global_position.z
	)
	if not position == target_pos:
		look_at(Vector3(player.position.x, position.y, player.position.z))
	
	#controls up or down movement and snaps if below a threshold
	if can_move and not should_rise:
		position += -transform.basis.z * speed * delta
	
	if too_low or should_rise:
		position.y += VERTICLE_SPEED * delta
	elif too_high:
		position.y -= VERTICLE_SPEED * delta
	
	if position.y <= LOWEST_POINT:
		position = Vector3.UP


func take_damage(player_damage: int):
	animation_tree.set(
		"parameters/OneShot/request", 
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)
	hp -= player_damage
	hurt_sound.play()
	
	if hp <= 0:
		die(self)


func die(called_node: Node) -> void: # if killed by bullets is true
	rigid_body_collisionshape.set_deferred("disabled", true)
	can_attack = false
	gravity_scale = 1
	set_physics_process(false)
	linear_velocity = _random_vector3()
	angular_velocity = _random_vector3()
	
	animation_tree.active = false
	animation_player.play("custom/fadeout")
	
	if called_node == self:
		death_sound.play()
		game_controller.mob_died()
		Global.coins += value
		Global.coins_made_this_run += value
	
	await get_tree().create_timer(RAGDOLL_TIME).timeout
	queue_free()


func _random_vector3() -> Vector3:
	return Vector3(
		randi_range(MIN_RANDOM_VECTOR3_VALUE, MAX_RANDOM_VECTOR3_VALUE) * [1, -1].pick_random(),
		randi_range(MIN_RANDOM_VECTOR3_VALUE, MAX_RANDOM_VECTOR3_VALUE),
		randi_range(MIN_RANDOM_VECTOR3_VALUE, MAX_RANDOM_VECTOR3_VALUE) * [1, -1].pick_random())


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body == player and can_attack:
		_on_attack_timer_timeout()
		attack_timer.start()
		in_attack_range = true


func _on_attack_area_body_exited(body: Node3D) -> void:
	if body == player:
		attack_timer.stop()
		in_attack_range = false


func _on_stop_movment_area_body_entered(body: Node3D) -> void:
	if body == player:
		can_move = false


func _on_stop_movment_area_body_exited(body: Node3D) -> void:
	if body == player:
		can_move = true


func _on_attack_timer_timeout() -> void:
	if type == SKY_TYPE_KEY:
		var new_projectile = sky_bat_projectile.instantiate()
		add_sibling(new_projectile)
		var x_offset = randf_range(-RANDOM_XZ_OFFSET, RANDOM_XZ_OFFSET)
		var z_offset = randf_range(-RANDOM_XZ_OFFSET, RANDOM_XZ_OFFSET)
		new_projectile.position = Vector3(
			player.position.x + x_offset, 
			position.y - SKY_BAT_Y_PROJECTILE_OFFSET,
			player.position.z + z_offset)
		new_projectile.damage = damage
		new_projectile.player_pos = player.position
		new_projectile.add_to_group("items")
		new_projectile.loaded()
	
	elif type == SHOOTER_TYPE_KEY:
		var new_projectile = shooter_bat_projectile.instantiate()
		add_sibling(new_projectile)
		new_projectile.position = shooter_projectile_spawn.global_position
		new_projectile.look_at(Vector3(
			player.position.x, 
			player.position.y + HALF_PLAYER_HEIGHT, 
			player.position.z))
		new_projectile.damage = damage
		new_projectile.add_to_group("items")
	
	else:
		attack_sound.stream = ATTACK_SOUNDS.pick_random()
		attack_sound.play()
		
		if player.hp - damage < 0:
			player.hp = 0
		else:
			player.hp -= damage
	
	if in_attack_range:
		attack_timer.start()


# height control functions
func _on_top_flying_area_area_entered(area: Area3D) -> void:
	if area in get_tree().get_nodes_in_group("bat_flight_plane"):
		too_low = true


func _on_top_flying_area_area_exited(area: Area3D) -> void:
	if area in get_tree().get_nodes_in_group("bat_flight_plane"):
		too_low = false


func _on_bottom_flying_area_area_entered(area: Area3D) -> void:
	if area in get_tree().get_nodes_in_group("bat_flight_plane"):
		too_high = false


func _on_bottom_flying_area_area_exited(area: Area3D) -> void:
	if area in get_tree().get_nodes_in_group("bat_flight_plane"):
		too_high = true


func _on_rise_area_body_entered(body: Node3D) -> void:
	if body is CSGBox3D:
		should_rise = true


func _on_rise_area_body_exited(body: Node3D) -> void:
	if body is CSGBox3D:
		should_rise = false


# transparent bat invisibility timers
func _on_invisible_interval_timeout() -> void:
	bat_model.visible = false
	rigid_body_collisionshape.set_deferred("disabled", true)
	transparent_duration.start()


func _on_invisible_duration_timeout() -> void:
	bat_model.visible = true
	rigid_body_collisionshape.set_deferred("disabled", false)
