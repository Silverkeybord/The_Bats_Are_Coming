extends StaticBody3D

@export var spawn_interval: int = 10
@export var mob_scene: PackedScene
@export var player: CharacterBody3D
@export var game_controller: Node3D
@export var mob_spawn: Marker3D
@export var enabled: bool = true
@export var spawn_timer: Timer


func start_spawning() -> void:
	spawn_timer.wait_time = spawn_interval + randf()
	spawn_timer.start()


func _on_timer_timeout() -> void:
	if Global.can_spawn_enemies and enabled:
		var weight = randf()
		var add: int = 0
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
		add_sibling(new_mob)
		
		spawn_timer.wait_time = spawn_interval + randf()
		
		new_mob.add_to_group("enemies")
