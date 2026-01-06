extends Area3D

const SPEED := 15.0
const MAX_DISTANCE := 100.0

var distance_travled := 0.0
var hit := false

@export var damage: int
@export var donk_sound: AudioStreamPlayer3D
@export var ball_mesh: MeshInstance3D
@export var collisionshape: CollisionShape3D

@onready var ball_mat: StandardMaterial3D


func _ready() -> void:
	var base_mat := ball_mesh.get_active_material(0)
	if base_mat:
		ball_mat = base_mat.duplicate()
		ball_mesh.set_surface_override_material(0, ball_mat)


func _physics_process(delta: float) -> void:
	position += -transform.basis.z * SPEED * delta
	distance_travled += SPEED * delta
	
	if distance_travled > MAX_DISTANCE and not hit:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player") and not Global.player_died:
		body.hp -= damage
		donk_sound.play()
		ball_mesh.queue_free()
		collisionshape.set_deferred("disable", true)
		await donk_sound.finished
		queue_free()
