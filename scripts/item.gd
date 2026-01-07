extends Area3D

enum SPAWN_TYPE {
	COIN,
	HEATH
}

const HP_HEAL_PERCENTAGE := 0.3

@export var value: int
@export var collisionshape: CollisionShape3D
@export var coin_sound: AudioStreamPlayer
@export var heal_sound: AudioStreamPlayer
@export var type: int
@export var coin_mesh: Node3D
@export var health_mesh: Node3D


func _ready() -> void:
	await get_tree().process_frame
	match type:
		SPAWN_TYPE.HEATH:
			coin_mesh.visible = false
			health_mesh.visible = true


func _on_body_entered(body: Node3D) -> void:
	if not body in get_tree().get_nodes_in_group("player"):
		return
	
	match type:
		SPAWN_TYPE.COIN:
			Global.coins += round(value * Global.base_stat_mult) 
			collisionshape.set_deferred("disabled", true)
			coin_sound.play()
			coin_mesh.visible = false
			await coin_sound.finished
			queue_free()
			
		SPAWN_TYPE.HEATH:
			var heal_amount = body.hp_bar.max_value * HP_HEAL_PERCENTAGE
			if body.hp + heal_amount > body.max_hp:
				body.hp = body.max_hp
			else:
				body.hp += heal_amount
			
			collisionshape.set_deferred("disabled", true)
			heal_sound.play()
			health_mesh.visible = false
			await heal_sound.finished
			queue_free()
