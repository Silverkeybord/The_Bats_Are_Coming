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

const INTRO_FADEOUT := "fade_out"

const VL_FIRST_DEATH_KEY := "first_death"
const VL_DEATH_KEY := "death"
const VL_INTRO_KEY := "intro"
const VL_BEAT_WAVE1_KEY := "beat_wave1"
const VL_BEAT_WAVE10_KEY := "beat_wave10"
const VL_BEAT_WAVE15_KEY := "beat_wave15"
const VL_BEAT_WAVE20_KEY := "beat_wave20"
const VL_BEAT_WAVE25_KEY := "beat_wave25"
const VL_GOOD_RUN_KEY := "good_run"

const GOOD_RUN_REQUIRMENTS := 200 # then times by global mult

var active_spawners: Node3D
var active_coin_spawners: Node3D
var active_map = maps.MAP1
var current_map = maps.MAP1

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
	await VoiceLines.play_vl(VL_INTRO_KEY)
	
	var player = get_tree().get_first_node_in_group("player")
	player.effect_animations.play(INTRO_FADEOUT)
	
	Global._lock_mouse_movement()
	start_new_run()


func start_new_run() -> void:
	# voice lines
	if Global.current_wave == 15:
		VoiceLines.play_vl(VL_BEAT_WAVE15_KEY)
	
	if Global.current_wave == 25:
		VoiceLines.play_vl(VL_BEAT_WAVE25_KEY)
	
	if (Global.coins_made_this_run >= GOOD_RUN_REQUIRMENTS * Global.base_stat_mult
		and Global.player_died):
		VoiceLines.play_vl(VL_GOOD_RUN_KEY)
	
	
	# starting all new wave setup
	if Global.player_died:
		if not VoiceLines.single_activation_vls[VL_FIRST_DEATH_KEY]:
			await VoiceLines.play_vl(VL_FIRST_DEATH_KEY)
		else:
			await VoiceLines.play_vl(VL_DEATH_KEY)
		
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
	# if on the correct threshold and voice lines at certian waves
	wave_visuals_animations.play("next_wave")
	
	if Global.current_wave in map_1_waves:
		Global.clear_coins_and_mobs()
		if current_map != maps.MAP1:
			
			if current_map == maps.MAP2:
				change_map_animations.play("map2-map1")
			elif current_map == maps.MAP3:
				change_map_animations.play("map3-map1")
				
			current_map = maps.MAP1
	
	if Global.current_wave in map_2_waves:
		Global.clear_coins_and_mobs()
		if current_map != maps.MAP2:
			
			if current_map == maps.MAP1:
				change_map_animations.play("map1-map2")
				VoiceLines.play_vl(VL_BEAT_WAVE10_KEY)
			elif current_map == maps.MAP3:
				change_map_animations.play("map3-map2")
				
			current_map = maps.MAP2
	
	elif Global.current_wave in map_3_waves:
		Global.clear_coins_and_mobs()
		if current_map != maps.MAP3:
			
			if current_map == maps.MAP1:
				change_map_animations.play("map1-map3")
				print("map1-map3 wait wtf is actually happening")
			elif current_map == maps.MAP2:
				change_map_animations.play("map2-map3")
				print("map2-map3")
				VoiceLines.play_vl(VL_BEAT_WAVE20_KEY)
			
			current_map = maps.MAP3
	
	
	# changes wave and mob values while they are not visible in the animation
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


# quite bulky so i put it in a funciton sets the map the the current one based 
# on an enum
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
		
		if Global.highest_wave == 1:
			VoiceLines.play_vl(VL_BEAT_WAVE1_KEY)
		
		Global.current_wave += 1
		if Global.current_wave > Global.highest_wave:
			Global.highest_wave = Global.current_wave
		
		start_new_run()


func reset_wave_display() -> void: 
	Global.mobs_left = 0
	Global.current_wave = Global.selected_wave
	main_wave_label.text = VISUAL_WAVE_TEXT + str(Global.current_wave)
	mob_counter.text = VISUAL_MOBS_TEXT + str(Global.mobs_left)
