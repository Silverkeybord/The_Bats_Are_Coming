extends Node3D

enum maps {
	MAP1,
	MAP2,
	MAP3
}

const WAVE_TEXT: String = "wave"
const VISUAL_WAVE_TEXT: String = "Wave: "
const VISUAL_MOBS_TEXT: String = "Mobs: "
const TIME_BEFORE_TEXT_CHANGE: float = 0.5

var active_spawners: Node3D
var active_coin_spawners: Node3D
var active_map = maps.MAP2

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
	Global.current_wave = Global.selected_wave
	Global.base_stat_mult = 1 + (Global.current_wave / Global.WAVE_MULT_DIVIDER)
	Global.player_died = false
	
	for spawners in get_tree().get_nodes_in_group("spawners"):
		spawners.enabled = false
	
	match active_map:
		maps.MAP1:
			active_spawners = map_1_spawners
			active_coin_spawners = map_1_coin_spawners
		maps.MAP2:
			active_spawners = map_2_spawners
			active_coin_spawners = map_2_coin_spawners
		maps.MAP3:
			active_spawners = map_3_spawners
			active_coin_spawners = map_3_coin_spawners
	
	var spawners = active_spawners.get_children()
	var coin_spawners = active_coin_spawners.get_children()
	var current_wave_text = WAVE_TEXT + str(Global.current_wave)
	
	for spawner in spawners:
		spawner.enabled = true
	
	Global.mutation_probabilities = (
		Global.WAVE_INFO[current_wave_text]["mutation_probilities"])
	
	Global.mob_stat_mult = 1 + roundi(Global.current_wave / Global.WAVE_MULT_DIVIDER)
	Global.can_spawn_enemies = true
	Global.total_enemies = Global.WAVE_INFO[current_wave_text]["amount"]
	Global.spawned_enemies = 0
	
	next_animations_wave.text = str(Global.current_wave)
	previous_animations_wave.text = str(Global.current_wave - 1)
	
	wave_visuals_animations.play("next_wave")
	await get_tree().create_timer(TIME_BEFORE_TEXT_CHANGE).timeout
	main_wave_label.text = VISUAL_WAVE_TEXT + str(Global.current_wave)
	Global.mobs_left = Global.WAVE_INFO[current_wave_text]["amount"]
	mob_counter.text = VISUAL_MOBS_TEXT + str(Global.mobs_left)
	
	
	await wave_visuals_animations.animation_finished
	
	for coin_spawner in coin_spawners:
		coin_spawner.start_timer()
	
	for spawner in spawners:
		if spawner:
			spawner.spawn_interval = Global.WAVE_INFO[current_wave_text]["interval"]
			spawner.start_spawning()


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
