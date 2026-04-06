extends Marker3D

enum SPAWN_TYPE {
	COIN,
	HEATH
}

@export var item_scene: PackedScene 
@export var timer: Timer
@export var enabled := false
@export var value := 10
@export var spawn_interval := 10
@export var spawn_probability := 0.1
@export var spawn_type := SPAWN_TYPE.COIN

@onready var spawn_node := get_tree().get_first_node_in_group("items_node") 

var item: Area3D


func _ready() -> void:
	add_to_group("coin_spawners")


func start_timer() -> void:
	timer.wait_time = spawn_interval
	if enabled:
		timer.start()


func _on_timer_timeout() -> void:
	if not enabled:
		return
	
	if item:
		return
	
	var chance = randf()
	if chance >= spawn_probability:
		return
	
	item = item_scene.instantiate()
	spawn_node.add_child(item)
	
	item.type = spawn_type
	item.global_position = global_position
	item.value = value
	item.add_to_group("items")
