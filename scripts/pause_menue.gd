extends Control

const REQUIRED_RESET_PRESSES := 4
const RESET_PROGRESS := "reset progress"
const FIRST_PRESS := "are you sure"
const SECOND_PRESS := "ARE YOU REALLY SURE"
const THIRD_PRESS := "ARE YOU REALLY REALLY SURE"

@export var music: AudioStreamPlayer
@export var reset_button : Button

var reset_presses := 0


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		reset_presses = 0
		reset_button.text = RESET_PROGRESS
		_pause_or_unpause()
		get_viewport().set_input_as_handled()


func _pause_or_unpause() -> void:
	var new_paused = not get_tree().paused
	get_tree().paused = new_paused
	visible = new_paused
	
	if new_paused:
		Global._unlock_mouse_movement()
		music.play()
		
	else:
		music.stop()
		if not Global.shop_open:
			Global._lock_mouse_movement()


func _on_unpause_pressed() -> void:
	_pause_or_unpause()


func _on_save_pressed() -> void:
	Global.save_game()


func _on_reset_progress_pressed() -> void:
	reset_presses += 1
	if reset_presses == 1:
		reset_button.text = FIRST_PRESS
	elif reset_presses == 2:
		reset_button.text = SECOND_PRESS
	elif reset_presses == 3:
		reset_button.text = THIRD_PRESS
	elif reset_presses == REQUIRED_RESET_PRESSES:
		Global.reset_game()
