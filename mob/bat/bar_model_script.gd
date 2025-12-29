extends Node3D

const SPEED = 5

@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var player: CharacterBody3D


func _physics_process(_delta: float) -> void:
	pass


func hurt() -> void:
	animation_tree.set(
		"parameters/OneShot/request", 
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)


func died() -> void:
	animation_tree.active = false
	animation_player.play("custom/fadeout")
	
	
