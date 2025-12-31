extends RigidBody3D

const RAGDOLL_TIME: int = 4
const MIN_RANDOM_VECTOR3_VALUE: int = 5
const MAX_RANDOM_VECTOR3_VALUE: int = 10
const BAT_VERTICLE_SPEED: float = 2
const BAT_SCORE: int = 1
const VERTICLE_SPEED: float = 1
const RANDOM_FLYING_HEIGHT: float = 0.2
const RANDOM_SPEED: float = 0.5
const ATTACK_AREA_RADIUS: float = 4.0
const MOVE_AREA_RADIUS: float = 0.4
const SKY_BAT_PROJECTILE_Y_OFFSET: float = 0.5

var in_attack_range: bool = false
var can_move: bool = true
var can_attack: bool = true
var flying_height: float
var damage: int
var hp: int
var value: int
var speed: float
var attack_interval: float
var bat_texture: Texture

# used to make the bat fly the correct distance above the ground
var too_high: bool = true
var too_low: bool = false

@export_group("in scene exports")
@export var bat_model: Node3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var attack_timer: Timer
@export var height_check_areas: Node3D
@export var bat_mesh: MeshInstance3D
@export var rigid_body_collisionshape: CollisionShape3D
@export var attack_area_collision: CollisionShape3D
@export var move_area_collision: CollisionShape3D

@export_group("out of scene exports")
@export var sky_bat_projectile: PackedScene
@export var player: CharacterBody3D
@export var game_controller: Node3D

@export_group("sounds")
@export var death_sound: AudioStreamPlayer3D
@export var hurt_sound: AudioStreamPlayer3D

@export_group("stats")
@export var type: String

@onready var bat_mat: StandardMaterial3D


func _ready() -> void:
	var bat_info = Global.ENEMY_INFO[type]
	
	value = bat_info["value"]
	damage = round(bat_info["damage"] * Global.base_stat_mult)
	hp = round(bat_info["health"] * Global.base_stat_mult)
	
	speed = bat_info["speed"]
	speed += randf_range(-RANDOM_SPEED, RANDOM_SPEED)
	
	flying_height = bat_info["flight_height"] 
	flying_height += randf_range(-RANDOM_FLYING_HEIGHT, RANDOM_FLYING_HEIGHT)
	
	attack_interval = bat_info["attack_interval"]
	
	var base_mat := bat_mesh.get_active_material(0)
	if base_mat:
		bat_mat = base_mat.duplicate()
		bat_mesh.set_surface_override_material(0, bat_mat)
		bat_mat.albedo_texture = bat_info["texture"]
	
	if type == "heavy" or type == "fast":
		bat_model.scale = Global.ENEMY_INFO[type]["scale"]
		rigid_body_collisionshape.scale = Global.ENEMY_INFO[type]["scale"]
		
	elif type == "transparent":
		bat_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	
	elif type == "sky":
		# height is multiplyd by 2 because of the round ends of the capsul 
		attack_area_collision.shape = CapsuleShape3D.new()
		attack_area_collision.shape.radius = ATTACK_AREA_RADIUS
		attack_area_collision.shape.height = flying_height + ATTACK_AREA_RADIUS * 2
		attack_area_collision.position.y = -(
			attack_area_collision.shape.height / 2 - ATTACK_AREA_RADIUS)
		
		move_area_collision.shape = CapsuleShape3D.new()
		move_area_collision.shape.radius = MOVE_AREA_RADIUS
		move_area_collision.shape.height = flying_height + MOVE_AREA_RADIUS * 2
		move_area_collision.position.y = -(
			move_area_collision.shape.height / 2 - MOVE_AREA_RADIUS)
		
	
	height_check_areas.position.y = -flying_height 


func _physics_process(delta: float) -> void:
	look_at(Vector3(player.position.x, position.y, player.position.z))
	
	if can_move:
		position += -transform.basis.z * speed * delta
	
	#print("the mob is to high is: ", too_high)
	#print("the mob is to low is: ", too_low)
	if too_high:
		position.y -= VERTICLE_SPEED * delta
	
	if too_low:
		position.y += VERTICLE_SPEED * delta


func take_damage(player_damage: int):
	animation_tree.set(
		"parameters/OneShot/request", 
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)
	hp -= player_damage
	hurt_sound.play()
	
	if hp <= 0:
		die(true)


func die(killed: bool) -> void: # if killed by bullets is true
	rigid_body_collisionshape.set_deferred("disabled", true)
	can_attack = false
	gravity_scale = 1
	game_controller.mob_died()
	set_physics_process(false)
	linear_velocity = _random_vector3()
	angular_velocity = _random_vector3()
	
	animation_tree.active = false
	animation_player.play("custom/fadeout")
	if not Global.player_died:
		death_sound.play()
	
	if killed:
		Global.coins += value
	
	await get_tree().create_timer(RAGDOLL_TIME).timeout
	queue_free()


func _random_vector3() -> Vector3:
	return Vector3(
		randi_range(MIN_RANDOM_VECTOR3_VALUE, MAX_RANDOM_VECTOR3_VALUE) * [1, -1].pick_random(),
		randi_range(MIN_RANDOM_VECTOR3_VALUE, MAX_RANDOM_VECTOR3_VALUE),
		randi_range(MIN_RANDOM_VECTOR3_VALUE, MAX_RANDOM_VECTOR3_VALUE) * [1, -1].pick_random())


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body == player:
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
	if not can_attack or type != "sky":
		return
	
	if type == "sky":
		var new_projectile = sky_bat_projectile.instantiate()
		add_sibling(new_projectile)
		new_projectile.position = Vector3(
			position.x, position.y - SKY_BAT_PROJECTILE_Y_OFFSET, position.z)
		new_projectile.damage = damage
		new_projectile.player_pos = player.position
		
	else:
		player.hp -= damage
	
	if in_attack_range:
		attack_timer.start()


# height contorl functions
func _on_top_flying_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("bat_flight_plane"):
		too_low = true


func _on_top_flying_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("bat_flight_plane"):
		too_low = false


func _on_bottom_flying_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("bat_flight_plane"):
		too_high = false


func _on_bottom_flying_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("bat_flight_plane"):
		too_high = true
