extends Node3D

enum POSSIBLE_ATTACKS {
	RAM,
	SHOOTING,
	FALLING_BALLS,
	SPAWNING,
}

const MAX_HP := 25000
const DAMAGE := 25
const ATTACK_INTERVAL := 8
const ATTACK_INTERVAL_OFFSET := 2

var current_attack
var can_normal_attack := true
var in_normal_attack_range := false

@export var animation_tree : AnimationTree
@export var hp := 25000
@export var hurt_sound : AudioStreamPlayer3D
@export var attack_timer : Timer
@export var normal_attack_timer : Timer

@onready var player := get_tree().get_first_node_in_group("player")

func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	look_at(player.position)
	
	if player.hp == 0:
		visible = false


func take_damage(player_damage: int):
	animation_tree.set(
		"parameters/OneShot/request", 
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)
	hp -= player_damage
	hurt_sound.play()
	
	if hp <= 0:
		_boss_died()


func start_boss() -> void:
	set_process(true)
	hp = MAX_HP
	attack_timer.wait_time = (ATTACK_INTERVAL + 
		randi_range(-ATTACK_INTERVAL_OFFSET, ATTACK_INTERVAL_OFFSET))
	
	attack_timer.start()
 

func _boss_died() -> void: 
	queue_free()


func _on_attack_timer_timeout() -> void:
	current_attack = POSSIBLE_ATTACKS.keys().pick_random()
	
	match current_attack:
		POSSIBLE_ATTACKS.RAM:
			pass
		POSSIBLE_ATTACKS.SHOOTING:
			pass
		POSSIBLE_ATTACKS.SPAWNING:
			pass
		POSSIBLE_ATTACKS.FALLING_BALLS:
			pass


func _on_normal_attack_area_body_entered(body: Node3D) -> void:
	if body == player:
		in_normal_attack_range = true
		normal_attack_timer.start()
		_on_normal_attack_timer_timeout()


func _on_normal_attack_area_body_exited(body: Node3D) -> void:
	if body == player:
		in_normal_attack_range = false


func _on_normal_attack_timer_timeout() -> void:
	if in_normal_attack_range:
		if player.hp - DAMAGE < 0:
			player.hp = 0
		else:
			player.hp -= DAMAGE
		
		normal_attack_timer.start()
	
