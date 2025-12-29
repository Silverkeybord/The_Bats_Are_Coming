extends Node3D

const WAVE_TEXT: String = "wave"
const VISUAL_WAVE_TEXT: String = "Wave: "
const VISUAL_MOBS_TEXT: String = "Mobs: "
const TIME_BEFORE_TEXT_CHANGE: float = 0.5

@export var spawners_parent: Node
@export var wave_visuals_animations: AnimationPlayer
@export var main_wave_label: Label
@export var next_animations_wave: Label
@export var previous_animations_wave: Label
@export var mob_counter: Label


func _ready() -> void:
	await get_tree().process_frame
	start_new_run()


func start_new_run() -> void:
	var spawners = spawners_parent.get_children()
	var current_wave_text = WAVE_TEXT + str(Global.current_wave)
	
	Global.mutation_probabilities = (
		Global.WAVE_INFO[current_wave_text]["mutation_probilities"])
	
	Global.mob_stat_mult = 1 + roundi(Global.current_wave / Global.WAVE_MULT_DIVIDER)
	Global.spawning_enemies = true
	Global.can_spawn_enemies = true
	
	next_animations_wave.text = str(Global.current_wave)
	previous_animations_wave.text = str(Global.current_wave - 1)
	
	wave_visuals_animations.play("next_wave")
	await get_tree().create_timer(TIME_BEFORE_TEXT_CHANGE).timeout
	main_wave_label.text = VISUAL_WAVE_TEXT + str(Global.current_wave)
	Global.mobs_left = Global.WAVE_INFO[current_wave_text]["amount"]
	mob_counter.text = VISUAL_MOBS_TEXT + str(Global.mobs_left)
	
	
	await wave_visuals_animations.animation_finished
	
	for spawner in spawners:
		spawner.spawn_interval = Global.WAVE_INFO[current_wave_text]["interval"]
		spawner.start_spawning()


func mob_died() -> void:
	Global.mobs_left -= 1
	mob_counter.text = VISUAL_MOBS_TEXT + str(Global.mobs_left)
	
	if Global.mobs_left == 0:
		Global.current_wave += 1
		start_new_run()
