extends Control


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_pause_or_unpause()
		get_viewport().set_input_as_handled()


func _pause_or_unpause() -> void:
	var new_paused = not get_tree().paused
	get_tree().paused = new_paused
	visible = new_paused
	
	if new_paused:
		Global._unlock_mouse_movement()
	else:
		Global._lock_mouse_movement()


func _on_unpause_pressed() -> void:
	_pause_or_unpause()
