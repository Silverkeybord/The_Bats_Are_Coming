extends AudioStreamPlayer3D

const VOICE_LINES := {
	# one time voice lines
	"intro": preload("res://sounds/VL/welcome to uhh something.mp3"),
	"first_death": preload("res://sounds/VL/first death.mp3"),
	"max_out_scale": preload("res://sounds/VL/meators will now falll.mp3"),
	"ten_k_coins": preload("res://sounds/VL/wow you_re a Rich boi.mp3"),
	"first_upgrade": preload("res://sounds/VL/your getting better.mp3"),
	
	"out_of_this_world": preload("res://sounds/VL/how did you get here +-50 zx.mp3"),
	"too_high": preload("res://sounds/VL/that_s not supposed to happen y5.mp3"),
	
	"sees_boss": preload("res://sounds/VL/thats one big bat.mp3"),
	"beat_the_game": preload("res://sounds/VL/gg thanks for playing.mp3"),
	
	"beat_wave25": preload("res://sounds/VL/are you ready.mp3"),
	"beat_wave20": preload("res://sounds/VL/5 left now.mp3"),
	"beat_wave15": preload("res://sounds/VL/10 left good going.mp3"),
	"beat_wave10": preload("res://sounds/VL/15 more waves.mp3"),
	"beat_wave1": preload("res://sounds/VL/24 more waves.mp3"),
	
	# multiple activation voice lines
	"death": [
		preload("res://sounds/VL/chicken nugget.mp3"),
		preload("res://sounds/VL/did that hurt it shouldn_t.mp3"),
		preload("res://sounds/VL/how many coins did you get.mp3"),
		preload("res://sounds/VL/welcome back.mp3"),
		preload("res://sounds/VL/did you fall off or were you touched by bats.mp3"),
		preload("res://sounds/SFX/fahhhhhhhhhhhhhh.mp3"),
		preload("res://sounds/SFX/fail-sound-effect.mp3"),
		preload("res://sounds/SFX/window-knock.mp3"),
		preload("res://sounds/SFX/indian-song.mp3"),
	],
	"good_run": preload("res://sounds/VL/that was a good run.mp3"),
	"more_than_30_bats": preload("res://sounds/VL/shoot the bats.mp3"),
	"load_a_save": preload("res://sounds/VL/haven_t you been here before.mp3"),
	"10m": preload("res://sounds/VL/played for 10 min.mp3"),
	"30m": preload("res://sounds/VL/played for 30 min.mp3"),
	"1h": preload("res://sounds/VL/played for 1h.mp3")
}

var single_activation_vls: Dictionary = {
	"intro": false,
	"first_death": false,
	"max_out_scale": false,
	"ten_k_coins": false,
	"first_upgrade": false,
	"out_of_this_world": false,
	"too_high": false,
	"sees_boos": false,
	"beat_the_game": false,
	"beat_wave25": false,
	"beat_wave20": false,
	"beat_wave15": false,
	"beat_wave10": false,
	"beat_wave1": false
}


func play_vl(vl: String):
	if playing:
		return
	
	if vl in single_activation_vls:
		if single_activation_vls[vl] == true:
			return
		
		print("single voice line played -- ", vl)
		single_activation_vls[vl] = true
		stream = VOICE_LINES[vl]
		self.play()
	
	else:
		print("multi voice line played -- ", vl)
		if VOICE_LINES[vl] is Array:
			stream = VOICE_LINES[vl].pick_random()
			self.play()
			
		else:
			stream = VOICE_LINES[vl]
			self.play()
	
	await finished
