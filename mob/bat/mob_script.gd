extends RigidBody3D

const MIN_SPEED: float = 2.0
const MAX_SPEED: float = 4.0
const RAGDOLL_TIME: int = 4
const MIN_RANDOM_VECTOR3_VALUE: int = 5
const MAX_RANDOM_VECTOR3_VALUE: int = 10
const BAT_VERTICLE_SPEED: float = 0.5
const BAT_SCORE: int = 1
const VERTICLE_SPEED: float = 4

var set_speed: float
var in_attack_range: bool = false
var can_attack: bool = true
var flying_height: float
var damage: int
var hp: int
var value: int
var speed: float
var attack_interval: float
var bat_texture: Texture

# used to make the bat fly the correct distance above the ground
var too_high: bool
var too_low: bool

@export_group("in scene exports")
@export var bat_model: Node3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var attack_timer: Timer
@export var height_check_areas: Node3D
@export var bat_mesh: MeshInstance3D

@export_group("out of scene exports")
@export var player: CharacterBody3D
@export var game_controller: Node3D

@export_group("sounds")
@export var death_sound: AudioStreamPlayer3D
@export var hurt_sound: AudioStreamPlayer3D

@export_group("stats")
@export var type: String


func _ready() -> void:
	var bat_info = Global.ENEMY_INFO[type]
	damage = bat_info["damage"]
	hp = bat_info["health"]
	speed = bat_info["speed"]
	flying_height = bat_info["flight_height"]
	attack_interval = bat_info["attack_interval"]
	bat_mesh.texture = bat_info["texture"]
	
	height_check_areas.position.y = -flying_height


func _physics_process(delta: float) -> void:
	look_at(Vector3(player.position.x, position.y, player.position.z))
	
	if not in_attack_range:
		position += -transform.basis.z * set_speed * delta
	
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
		die()


func die() -> void:
	can_attack = false
	gravity_scale = 1
	Global.coins += 1
	game_controller.mob_died()
	set_physics_process(false)
	linear_velocity = _random_vector3()
	angular_velocity = _random_vector3()
	
	animation_tree.active = false
	animation_player.play("custom/fadeout")
	death_sound.play()
	
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


func _on_attack_timer_timeout() -> void:
	if not can_attack:
		return
	
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
