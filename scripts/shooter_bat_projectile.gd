extends Area3D

const SPEED := 8.0
const MAX_DISTANCE := 100.0

var distance_travled := 0.0

@export var damage: int


func _physics_process(delta: float) -> void:
	position += -transform.basis.z * SPEED * delta
	distance_travled += SPEED * delta


func _on_body_entered(body: Node3D) -> void:
	if body in get_tree().get_nodes_in_group("player"):
		body.hp -= damage
		queue_free()
