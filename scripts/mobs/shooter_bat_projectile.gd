extends Area3D

const SPEED := 20.0
const MAX_DISTANCE := 100.0
const HIT_SOUND := preload("res://sounds/SFX/critical-hit-sounds-effect.mp3")
const TEMP_SOUND_SCRIPT := preload("res://scripts/temp_sound.gd")

var distance_travled := 0.0
var hit := false

@export var damage: int
@export var ball_mesh: MeshInstance3D
@export var collisionshape: CollisionShape3D
@export var temp_sound_node: Node

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
		
		var audiostreamplayer3D = AudioStreamPlayer3D.new()
		audiostreamplayer3D.set_script(TEMP_SOUND_SCRIPT)
		temp_sound_node.add_child(audiostreamplayer3D)
		audiostreamplayer3D.stream = HIT_SOUND
		audiostreamplayer3D.position = global_position
		audiostreamplayer3D.play()
		
		ball_mesh.queue_free()
		collisionshape.set_deferred("disable", true)
		await audiostreamplayer3D.finished
		queue_free()
