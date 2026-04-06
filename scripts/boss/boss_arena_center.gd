extends Node3D

@export var boss : RigidBody3D
@export var boss_related_animations : AnimationPlayer


func start_boss() -> void:
	boss_related_animations.play("descend_boss")
	boss.set_process(true)
