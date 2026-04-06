extends Node3D

@export var arrow_indicator : MeshInstance3D
@export var path_activation_area : Area3D
@export var open_door : Area3D
@export var boss_activation : Area3D
@export var boss_arena_center : Node3D

@export var boss_related_animations : AnimationPlayer


# boss related functions
func _on_path_activation_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player") and not Global.path_open:
		Global.path_open = true
		arrow_indicator.visible = false
		boss_related_animations.play("open_path")
		await boss_related_animations.animation_finished


func _on_open_door_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player"):
		boss_related_animations.play("open_door")


func _on_boss_activation_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player") and not Global.fighting_boss:
		Global.fighting_boss = true
		boss_related_animations.play("close_door")
		await boss_related_animations.animation_finished
		boss_related_animations.play("descend_boss")
		boss_arena_center.start_boss()
