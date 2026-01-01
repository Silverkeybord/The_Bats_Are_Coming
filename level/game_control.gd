extends Node3D

enum maps {
	MAP1,
	MAP2,
	MAP3
}

const WAVE_TEXT := "wave"
const VISUAL_WAVE_TEXT := "Wave: "
const VISUAL_MOBS_TEXT := "Mobs: "
const TIME_BEFORE_TEXT_CHANGE := 0.5
const map_1_waves := [1, 5]
const map_2_waves := [10, 15]
const map_3_waves := [20, 25]
const map_2_threshlond := 10
const map_3_threshlond := 20

const GROUP_SPAWNERS := "spawners"
const GROUP_COIN_SPAWNERS := "coin_spawners"
const KEY_MUTATION_PROB := "mutation_probilities"

var active_spawners: Node3D
var active_coin_spawners: Node3D
var active_map = maps.MAP2

@export_group("map exports")
@export var change_map_animations: AnimationPlayer
@export var bat_flight_plane_2: Area3D
@export var bat_flight_plane_3: Area3D

@export_group("spawners")
@export var map_1_spawners: Node3D
@export var map_2_spawners: Node3D
@export var map_3_spawners: Node3D
@export var map_1_coin_spawners: Node3D
@export var map_2_coin_spawners: Node3D
@export var map_3_coin_spawners: Node3D

@export_group("UI")
@export var wave_visuals_animations: AnimationPlayer
@export var main_wave_label: Label
@export var next_animations_wave: Label
@export var previous_animations_wave: Label
@export var mob_counter: Label


func _ready() -> void:
	await get_tree().process_frame
	start_new_run()


func start_new_run() -> void:
	if Global.player_died:
		Global.current_wave = Global.selected_wave
	
	Global.base_stat_mult = 1 + (Global.current_wave / Global.WAVE_MULT_DIVIDER)
	Global.player_died = false
	
	# disables all enabled spawners
	for spawner in get_tree().get_nodes_in_group("spawners"):
		if spawner.enabled:
			spawner.enabled = false
	
	for coin_spawners in get_tree().get_nodes_in_group("coin_spawners"):
		if coin_spawners.enabled:
			coin_spawners.enabled = false
	
	_set_active_map_and_spawners()
	
	var current_wave_text = WAVE_TEXT + str(Global.current_wave)
	
	Global.mutation_probabilities = (
		Global.WAVE_INFO[current_wave_text]["mutation_probilities"])
	
	Global.mob_stat_mult = 1 + roundi(Global.current_wave / Global.WAVE_MULT_DIVIDER)
	Global.can_spawn_enemies = true
	Global.total_enemies = Global.WAVE_INFO[current_wave_text]["amount"]
	Global.spawned_enemies = 0
	
	next_animations_wave.text = str(Global.current_wave)
	previous_animations_wave.text = str(Global.current_wave - 1)
	
	# sets main mob and wave text while they cant be seen and changes map
	# if on the correct threshold
	wave_visuals_animations.play("next_wave")
	
	if Global.current_wave == map_2_threshlond:
		Global.clear_coins_and_mobs()
		change_map_animations.play("map1-map2")
		
	elif Global.current_wave == map_3_threshlond:
		change_map_animations.play("map2-map3")
		Global.clear_coins_and_mobs()
		
	
	await get_tree().create_timer(TIME_BEFORE_TEXT_CHANGE).timeout
	main_wave_label.text = VISUAL_WAVE_TEXT + str(Global.current_wave)
	Global.mobs_left = Global.WAVE_INFO[current_wave_text]["amount"]
	mob_counter.text = VISUAL_MOBS_TEXT + str(Global.mobs_left)
	
	await wave_visuals_animations.animation_finished
	
	# enables the current maps spawners 
	var spawners = active_spawners.get_children()
	var coin_spawners = active_coin_spawners.get_children()
	
	for coin_spawner in coin_spawners:
		coin_spawner.enabled = true
		coin_spawner.start_timer()
	
	for spawner in spawners:
		spawner.enabled = true
		spawner.spawn_interval = Global.WAVE_INFO[current_wave_text]["interval"]
		spawner.start_spawning()


func _set_active_map_and_spawners() -> void:
	if Global.current_wave in map_1_waves:
		active_map = maps.MAP1
	elif Global.current_wave in map_2_waves:
		active_map = maps.MAP2
	elif Global.current_wave in map_3_waves:
		active_map = maps.MAP3
	
	match active_map:
		maps.MAP1:
			active_spawners = map_1_spawners
			active_coin_spawners = map_1_coin_spawners
			bat_flight_plane_2.set_deferred("monitorable", false)
			bat_flight_plane_3.set_deferred("monitorable", false)

		maps.MAP2:
			active_spawners = map_2_spawners
			active_coin_spawners = map_2_coin_spawners
			bat_flight_plane_2.set_deferred("monitorable", true)
			bat_flight_plane_3.set_deferred("monitorable", false)

		maps.MAP3:
			active_spawners = map_3_spawners
			active_coin_spawners = map_3_coin_spawners
			bat_flight_plane_2.set_deferred("monitorable", false)
			bat_flight_plane_3.set_deferred("monitorable", true)



func mob_died() -> void:
	Global.mobs_left -= 1
	mob_counter.text = VISUAL_MOBS_TEXT + str(Global.mobs_left)
	
	if Global.mobs_left == 0 and not Global.player_died:
		Global.current_wave += 1
		if Global.current_wave > Global.highest_wave:
			Global.highest_wave = Global.current_wave
		start_new_run()


func reset_wave_display() -> void: 
	Global.mobs_left = 0
	Global.current_wave = Global.selected_wave
	main_wave_label.text = VISUAL_WAVE_TEXT + str(Global.current_wave)
	mob_counter.text = VISUAL_MOBS_TEXT + str(Global.mobs_left)
