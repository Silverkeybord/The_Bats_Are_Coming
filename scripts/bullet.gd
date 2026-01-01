extends Area3D

const SPEED := 60 # meters / s
const RANGE := 200 # distance travled before despawn
const BULLET_SCALE_FACTOR := 0.2

var travled_distance := 0.0
var damage := Global.damage
var durability := Global.durability
var last_pos: Vector3
var can_despawn_to_ground := false

@export var shoot_stream_player: AudioStreamPlayer
@export var collision_shape: CollisionShape3D


func _ready() -> void:
	shoot_stream_player.play()
	scale = Global.bullet_scale * BULLET_SCALE_FACTOR


func _physics_process(delta: float) -> void:
	position += (-transform.basis.z * SPEED * delta) / scale
	travled_distance += SPEED * delta


func _on_body_entered(body: Node3D) -> void:
	if body.has_meta("mob"):
		durability -= 1
		body.take_damage(damage)

		if durability <= 0:
			queue_free()
	elif (not body in get_tree().get_nodes_in_group("player") and 
		can_despawn_to_ground):
		queue_free()


func _on_bullet_despawn_buffer_timeout() -> void:
	can_despawn_to_ground = true
