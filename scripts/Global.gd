extends Node

const GRAVITY := -22 # meters per second per second
const WAVE_MULT_DIVIDER := 8.0
const BOSS_WAVE := 26
const SHOP_INFO: Dictionary = {
	"damage" : {
		"levels": 10,
		"cost" : {
			"1": 10,
			"2": 25,
			"3": 50,
			"4": 100,
			"5": 250,
			"6": 500,
			"7": 750,
			"8": 1000,
			"9": 2500,
			"10": 5000
		},
		"value" : {
			"0": 1,
			"1": 2,
			"2": 3,
			"3": 4,
			"4": 5,
			"5": 8,
			"6": 10,
			"7": 12,
			"8": 15,
			"9": 20,
			"10": 25
		}
	},
	"firerate" : {
		"levels": 4,
		"cost" : {
			"1": 100,
			"2": 500,
			"3": 1000,
			"4": 2500,
		},
		"value" : {
			"0": 0.25,
			"1": 0.2,
			"2": 0.15,
			"3": 0.10,
			"4": 0.05,
		}
	},
	"health" : {
		"levels": 9,
		"cost" : {
			"1": 10,
			"2": 25,
			"3": 50,
			"4": 100,
			"5": 250,
			"6": 500,
			"7": 750,
			"8": 1000,
			"9": 2500,
		},
		"value" : {
			"0": 10,
			"1": 15,
			"2": 20,
			"3": 30,
			"4": 40,
			"5": 50,
			"6": 75,
			"7": 100,
			"8": 150,
			"9": 250,
		}
	},
	"bullet_scale" : {
		"levels": 4,
		"cost" : {
			"1": 100,
			"2": 500,
			"3": 1000,
			"4": 2500,
		},
		"value" : {
			"0": 1,
			"1": 2,
			"2": 3,
			"3": 4,
			"4": 5
		}
	},
	"durability" : {
		"levels": 4,
		"cost" : {
			"1": 250,
			"2": 1000,
			"3": 2500,
			"4": 5000,
		},
		"value" : {
			"0": 1,
			"1": 2,
			"2": 4,
			"3": 6,
			"4": 10
		}
	},
}
const WAVE_INFO: Dictionary = {
	"wave66": {
		"amount": 1,
		"interval": 1,
		"mutation_probilities": {
			"normal": 0.99,
			"fast": 0.,
			"heavy": 0.,
			"shooter": 0.5,
			"sky": 0.5,
			"transparent": 0.
		}
	},
	"wave1": {
		"amount": 10,
		"interval": 9,
		"mutation_probilities": {
			"normal": 1,
			"fast": 0.,
			"heavy": 0.,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave2": {
		"amount": 15,
		"interval": 9,
		"mutation_probilities": {
			"normal": 0.96,
			"fast": 0.04,
			"heavy": 0.,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave3": {
		"amount": 15,
		"interval": 8,
		"mutation_probilities": {
			"normal": 0.94,
			"fast": 0.04,
			"heavy": 0.02,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave4": {
		"amount": 20,
		"interval": 7,
		"mutation_probilities": {
			"normal": 0.92,
			"fast": 0.04,
			"heavy": 0.04,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave5": {
		"amount": 25,
		"interval": 6,
		"mutation_probilities": {
			"normal": 0.90,
			"fast": 0.06,
			"heavy": 0.04,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave6": {
		"amount": 20,
		"interval": 6,
		"mutation_probilities": {
			"normal": 0.88,
			"fast": 0.08,
			"heavy": 0.04,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave7": {
		"amount": 20,
		"interval": 5,
		"mutation_probilities": {
			"normal": 0.86,
			"fast": 0.06,
			"heavy": 0.08,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave8": {
		"amount": 20,
		"interval": 5,
		"mutation_probilities": {
			"normal": 0.84,
			"fast": 0.15,
			"heavy": 0.01,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave9": {
		"amount": 20,
		"interval": 5,
		"mutation_probilities": {
			"normal": 0.82,
			"fast": 0.03,
			"heavy": 0.15,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave10": {
		"amount": 25,
		"interval": 5,
		"mutation_probilities": {
			"normal": 0.8,
			"fast": 0.1,
			"heavy": 0.1,
			"shooter": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave11": {
		"amount": 15,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.78,
			"fast": 0.06,
			"heavy": 0.06,
			"shooter": 0.1,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave12": {
		"amount": 20,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.76,
			"fast": 0.09,
			"heavy": 0.09,
			"shooter": 0.06,
			"sky": 0.0,
			"transparent": 0.
		}
	},
	"wave13": {
		"amount": 10,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.74,
			"fast": 0.04,
			"heavy": 0.04,
			"shooter": 0.1,
			"sky": 0.08,
			"transparent": 0.
		}
	},
	"wave14": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.72,
			"fast": 0.24,
			"heavy": 0.02,
			"shooter": 0.,
			"sky": 0.02,
			"transparent": 0.
		}
	},
	"wave15": {
		"amount": 35,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.68,
			"fast": 0.1,
			"heavy": 0.02,
			"shooter": 0.1,
			"sky": 0.1,
			"transparent": 0.
		}
	},
	"wave16": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.64,
			"fast": 0.1,
			"heavy": 0.06,
			"shooter": 0.1,
			"sky": 0.1,
			"transparent": 0.
		}
	},
	"wave17": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.60,
			"fast": 0.16,
			"heavy": 0.,
			"shooter": 0.18,
			"sky": 0.06,
			"transparent": 0.
		}
	},
	"wave18": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.1,
			"fast": 0.1,
			"heavy": 0.,
			"shooter": 0.4,
			"sky": 0.4,
			"transparent": 0.
		}
	},
	"wave19": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.4,
			"fast": 0.5,
			"heavy": 0.,
			"shooter": 0.05,
			"sky": 0.05,
			"transparent": 0.
		}
	},
	"wave20": {
		"amount": 30,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.50,
			"fast": 0.05,
			"heavy": 0.05,
			"shooter": 0.1,
			"sky": 0.1,
			"transparent": 0.2
		}
	},
	"wave21": {
		"amount": 40,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.52,
			"fast": 0.1,
			"heavy": 0.1,
			"shooter": 0.07,
			"sky": 0.08,
			"transparent": 0.13
		}
	},
	"wave22": {
		"amount": 30,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.,
			"fast": 0.8,
			"heavy": 0.,
			"shooter": 0.1,
			"sky": 0.1,
			"transparent": 0.
		}
	},
	"wave23": {
		"amount": 40,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.,
			"fast": 0.1,
			"heavy": 0.4,
			"shooter": 0.4,
			"sky": 0.,
			"transparent": 0.1
		}
	},
	"wave24": {
		"amount": 40,
		"interval": 2,
		"mutation_probilities": {
			"normal": 0.20,
			"fast": 0.2,
			"heavy": 0.2,
			"shooter": 0.2,
			"sky": 0.2,
			"transparent": 0.2
		}
	},
	"wave25": {
		"amount": 100,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.,
			"fast": 0.24,
			"heavy": 0.16,
			"shooter": 0.20,
			"sky": 0.20,
			"transparent": 0.2
		}
	}
}
const ENEMY_INFO: Dictionary = {
	"normal": {
		"value": 1,
		"damage": 1,
		"speed": 3,
		"health": 5,
		"flight_height": 1,
		"attack_interval": 1.5,
		"texture": preload("res://textres/normal_palette.png")
	},
	"fast": {
		"value": 2,
		"damage": 1,
		"speed": 6.5,
		"health": 3,
		"flight_height": 1.5,
		"attack_interval": 0.8,
		"texture": preload("res://textres/fast_palette.png"),
		"scale": Vector3(0.8, 0.8, 0.8)
	},
	"heavy": {
		"value": 3,
		"damage": 4,
		"speed": 2.5,
		"health": 40,
		"flight_height": 0.6,
		"attack_interval": 2.5,
		"texture": preload("res://textres/heavy_palette.png"),
		"scale": Vector3(2, 2, 2)
	},
	"sky": {
		"value": 4,
		"damage": 2,
		"speed": 5.8,
		"health": 5,
		"flight_height": 6,
		"attack_interval": 1,
		"texture": preload("res://textres/sky_palette.png"),
	},
	"transparent": {
		"value": 5,
		"damage": 3,
		"speed": 3,
		"health": 25,
		"flight_height": 1,
		"attack_interval": 1.8,
		"texture": preload("res://textres/transparent_palette.png"),
		"invisible_interval": 4,
		"invisible_duration": 0.4,
		"speed_boost": 8.0
	},
	"shooter": {
		"value": 3,
		"damage": 2,
		"speed": 5.8,
		"health": 10,
		"flight_height": 2,
		"attack_interval": 2,
		"texture": preload("res://textres/shooter_palette.png"),
	}
}
const ENEMY_KEYS: Array = [
	"normal", "fast", "heavy", "shooter", "sky", "transparent"
]
const AVAIBLE_SELECTABLE_WAVES: Array = [1, 5, 10, 15, 20, 25]


# shop upgrades and values
var damage_level := 0
var firerate_level := 0
var hp_level := 0
var scale_level := 0
var durabilty_level := 0

var damage := 1
var durability := 1
var bullet_scale: Vector3 = Vector3(1, 1, 1)

# player information
var player_died := true
var coins := 100000
var lock_movement := true
var shop_open := false

# current wave info
var mobs_left: int
var can_spawn_enemies := true
var spawned_enemies: int
var total_enemies: int
var mutation_probabilities: Dictionary

# boss related varibles
var going_to_boss := false
var fighting_boss := false

# wave information
var current_wave := 1
var highest_wave := 26
var selected_wave := 26
var base_stat_mult := 1.0

# voice line stuff
var coins_made_this_run := 0


func _lock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lock_movement = false


func _unlock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	lock_movement = true


func clear_items_and_mobs() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var items_alive = get_tree().get_nodes_in_group("items")
	
	for item in items_alive:
		item.queue_free()
	
	for enemy in enemies:
		enemy.die(self)
