extends Area3D

@export var value: int
@export var pickup_sound: AudioStreamPlayer
@export var mesh: Node3D


func _on_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player"):
		Global.coins += round(value * Global.base_stat_mult) 
		pickup_sound.play()
		mesh.visible = false
		await pickup_sound.finished
		queue_free()
