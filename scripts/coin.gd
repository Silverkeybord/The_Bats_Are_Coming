extends Area3D

@export var value: int
@export var pickup_sound: AudioStreamPlayer
@export var mesh: Node3D


func _on_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player"):
		Global.coins += value
		pickup_sound.play()
		mesh.visible = false
		await pickup_sound.finished
		queue_free()
