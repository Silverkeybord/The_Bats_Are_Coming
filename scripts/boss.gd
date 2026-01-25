extends Node3D

const damage := 25

@export var player : CharacterBody3D
@export var animation_tree : AnimationTree
@export var hp := 25000
@export var hurt_sound : AudioStreamPlayer3D


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	look_at(player.position)


func take_damage(player_damage: int):
	animation_tree.set(
		"parameters/OneShot/request", 
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)
	hp -= player_damage
	hurt_sound.play()
	
	print(hp)
	
	if hp <= 0:
		_boss_died()


func start_boss() -> void:
	set_process(true)
 

func _boss_died() -> void: 
	print("killed")
	queue_free()
