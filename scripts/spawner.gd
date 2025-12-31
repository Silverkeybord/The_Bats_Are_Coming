extends StaticBody3D

@export_group("in_scene_exports")
@export var spawn_timer: Timer
@export var mob_spawn: Marker3D

@export_group("values")
@export var spawn_interval: int
@export var enabled: bool = true

@export_group("external_exports")
@export var mob_scene: PackedScene
@export var player: CharacterBody3D
@export var game_controller: Node3D
@export var enemy_spawn_node: Node


func start_spawning() -> void:
	spawn_timer.wait_time = spawn_interval + (randf() * [1, -1].pick_random())
	spawn_timer.start()


func _on_timer_timeout() -> void:
	if Global.can_spawn_enemies and enabled:
		Global.spawned_enemies += 1
		
		if Global.spawned_enemies == Global.total_enemies:
			Global.can_spawn_enemies = false
		
		var weight = randf()
		var add: float = 0
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
		
		spawn_timer.wait_time = spawn_interval + randf()
		
		new_mob.add_to_group("enemies")
 
