extends RigidBody3D

const RANDOM_HOLD_TIME := 0.2
const APPLIED_GRAVITY := 6
const Y_PROJECTILE_OFFSET := -0.3
const DONK_SOUND := preload("res://sounds/SFX/bongo-hit.mp3")
const TEMP_SOUND_SCRIPT := preload("res://scripts/temp_sound.gd")


var hit := false

@export var damage: int
@export var player_pos: Vector3
@export var ball_mesh: MeshInstance3D
@export var animation_player: AnimationPlayer
@export var area_collisionshape: CollisionShape3D
@export var temp_sound_node: Node

@onready var ball_mat: StandardMaterial3D


func loaded() -> void:
	area_collisionshape.set_deferred("disabled", false)
	var base_mat := ball_mesh.get_active_material(0)
	if base_mat:
		ball_mat = base_mat.duplicate()
		ball_mesh.set_surface_override_material(0, ball_mat)
	
	await get_tree().create_timer(randf_range(0, RANDOM_HOLD_TIME)).timeout
	gravity_scale = APPLIED_GRAVITY


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player") and not hit and not Global.player_died:
		hit = true
		body.hp -= damage
		
		var audiostreamplayer3D = AudioStreamPlayer3D.new()
		audiostreamplayer3D.set_script(TEMP_SOUND_SCRIPT)
		temp_sound_node.add_child(audiostreamplayer3D)
		audiostreamplayer3D.stream = DONK_SOUND
		audiostreamplayer3D.position = global_position
		audiostreamplayer3D.play()
		
		ball_mesh.queue_free()
		await audiostreamplayer3D.finished
		queue_free()


func _on_timer_timeout() -> void:
	if hit:
		return
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	queue_free()
