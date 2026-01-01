extends StaticBody3D

const RANDOM_SPAWN_OFFSET := 0.2 

@export_group("in_scene_exports")
@export var spawn_timer: Timer
@export var mob_spawn: Marker3D

@export_group("values")
@export var spawn_interval: int
@export var enabled := true

@export_group("external_exports")
@export var mob_scene: PackedScene
@export var player: CharacterBody3D
@export var game_controller: Node3D
@export var enemy_spawn_node: Node


func _ready() -> void:
	add_to_group("spawners")


func start_spawning() -> void:
	await get_tree().create_timer(
		randf_range(-RANDOM_SPAWN_OFFSET, RANDOM_SPAWN_OFFSET)).timeout
	_on_timer_timeout()
	
	spawn_timer.wait_time = spawn_interval + (
		randf_range(-RANDOM_SPAWN_OFFSET, RANDOM_SPAWN_OFFSET))
	spawn_timer.start()


func _on_timer_timeout() -> void:
	if Global.can_spawn_enemies and enabled:
		Global.spawned_enemies += 1
		
		if Global.spawned_enemies == Global.total_enemies:
			Global.can_spawn_enemies = false
		
		var weight = randf()
		var add := 0.0
		var selection: String

		for x in Global.ENEMY_KEYS:
			add += Global.mutation_probabilities[x]
			selection = x
		
			if weight <= add:
				break
		
		
		var new_mob = mob_scene.instantiate()
		new_mob.player = player
		new_mob.game_controller = game_controller
		new_mob.position = mob_spawn.global_position
		new_mob.type = selection
		enemy_spawn_node.add_child(new_mob)
		
		spawn_timer.wait_time = spawn_interval + (
			randf_range(-RANDOM_SPAWN_OFFSET, RANDOM_SPAWN_OFFSET))
		
		new_mob.add_to_group("enemies")
 
