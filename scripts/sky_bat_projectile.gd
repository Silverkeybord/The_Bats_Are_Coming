extends RigidBody3D

const RANDOM_HOLD_TIME: float = 0.2

@export var damage: int
@export var player_pos: Vector3
@export var mesh: MeshInstance3D
@export var animation_player: AnimationPlayer

@onready var ball_mat: StandardMaterial3D


func _ready() -> void:
	var base_mat := mesh.get_active_material(0)
	if base_mat:
		ball_mat = base_mat.duplicate()
		mesh.set_surface_override_material(0, ball_mat)
	
	await get_tree().create_timer(randf_range(0, RANDOM_HOLD_TIME)).timeout
	gravity_scale = 4


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player"):
		body.hp -= damage
		queue_free()


func _on_timer_timeout() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	queue_free()
