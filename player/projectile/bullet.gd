extends Area3D

const SPEED: int = 60 # meters / s
const RANGE: int = 200 # distance travled before despawn
const BULLET_SCALE_FACTOR: float = 0.2

var travled_distance: float = 0.0
var damage: int  = Global.damage
var durability: int = Global.durability


func _ready() -> void:
	scale = Global.bullet_scale * BULLET_SCALE_FACTOR


func _physics_process(delta: float) -> void:
	position += (-transform.basis.z * SPEED * delta) / scale
	travled_distance += SPEED * delta
	
	if travled_distance >= RANGE:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.has_meta("mob"):
		durability -= 1
		body.take_damage(damage)
		
		if durability <= 0:
			queue_free()
	elif not body in get_tree().get_nodes_in_group("player"):
		queue_free()
