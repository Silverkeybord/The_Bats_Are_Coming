extends Marker3D

@export var coin_scene: PackedScene 
@export var timer: Timer
@export var coin_spawn_node: Node 
@export var enabled := false
@export var value := 10
@export var spawn_interval := 10
@export var SPAWN_PROBIBLITY := 0.1

var coin: Area3D


func _ready() -> void:
	add_to_group("coin_spawners")


func start_timer() -> void:
	timer.wait_time = spawn_interval
	if enabled:
		timer.start()


func _on_timer_timeout() -> void:
	if not enabled:
		return
	
	if coin:
		return
	
	var chance = randf()
	if chance >= SPAWN_PROBIBLITY:
		return
	
	coin = coin_scene.instantiate()
	coin_spawn_node.add_child(coin)
	coin.global_position = global_position
	coin.value = value
	coin.add_to_group("coins")
