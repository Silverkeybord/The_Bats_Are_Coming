extends Node

const GRAVITY: float = -20 # meters per second per second
const WAVE_MULT_DIVIDER: float = 6.0
const SHOP_INFO: Dictionary = {
	"damage" : {
		"levels": 6,
		"cost" : {
			"1": 10,
			"2": 25,
			"3": 50,
			"4": 100,
			"5": 250,
			"6": 1000
		},
		"value" : {
			"0": 1,
			"1": 2,
			"2": 3,
			"3": 4,
			"4": 5,
			"5": 8,
			"6": 10
		}
	},
	"firerate" : {
		"levels": 4,
		"cost" : {
			"1": 100,
			"2": 250,
			"3": 500,
			"4": 1000,
		},
		"value" : {
			"0": 0.25,
			"1": 0.2,
			"2": 0.15,
			"3": 0.1,
			"4": 0.05,
		}
	},
	"health" : {
		"levels": 8,
		"cost" : {
			"1": 10,
			"2": 25,
			"3": 50,
			"4": 100,
			"5": 250,
			"6": 500,
			"7": 750,
			"8": 1000
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
			"8": 150
		}
	},
	"bullet_scale" : {
		"levels": 4,
		"cost" : {
			"1": 100,
			"2": 500,
			"3": 1000,
			"4": 19999,
		},
		"value" : {
			"0": 1,
			"1": 2,
			"2": 3,
			"3": 4,
			"4": 10
		}
	},
	"durability" : {
		"levels": 4,
		"cost" : {
			"1": 250,
			"2": 1000,
			"3": 2500,
			"4": 14999,
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
		"amount": 100,
		"interval": 1,
		"mutation_probilities": {
			"normal": 0.,
			"fast": 0.,
			"heavy": 0.,
			"sky": 1,
			"transparent": 0.
		}
	},
	"wave1": {
		"amount": 10,
		"interval": 9,
		"mutation_probilities": {
			"normal": 0.98,
			"fast": 0.02,
			"heavy": 0.,
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave2": {
		"amount": 15,
		"interval": 9,
		"mutation_probilities": {
			"normal": 0.96,
			"fast": 0.02,
			"heavy": 0.02,
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
			"sky": 0.,
			"transparent": 0.
		}
	},
	"wave6": {
		"amount": 20,
		"interval": 6,
		"mutation_probilities": {
			"normal": 0.88,
			"fast": 0.6,
			"heavy": 0.4,
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
			"heavy": 0.06,
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
			"sky": 0.04,
			"transparent": 0.
		}
	},
	"wave12": {
		"amount": 20,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.76,
			"fast": 0.06,
			"heavy": 0.06,
			"sky": 0.06,
			"transparent": 0.
		}
	},
	"wave13": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.74,
			"fast": 0.5,
			"heavy": 0.5,
			"sky": 0.16,
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
			"sky": 0.02,
			"transparent": 0.
		}
	},
	"wave15": {
		"amount": 35,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.7,
			"fast": 0.1,
			"heavy": 0.1,
			"sky": 0.1,
			"transparent": 0.
		}
	},
	"wave16": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.68,
			"fast": 0.1,
			"heavy": 0.12,
			"sky": 0.1,
			"transparent": 0.
		}
	},
	"wave17": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.66,
			"fast": 0.1,
			"heavy": 0.1,
			"sky": 0.14,
			"transparent": 0.
		}
	},
	"wave18": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.64,
			"fast": 0.08,
			"heavy": 0.2,
			"sky": 0.08,
			"transparent": 0.
		}
	},
	"wave19": {
		"amount": 25,
		"interval": 4,
		"mutation_probilities": {
			"normal": 0.60,
			"fast": 0.2,
			"heavy": 0.2,
			"sky": 0.1,
			"transparent": 0.
		}
	},
	"wave20": {
		"amount": 45,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.56,
			"fast": 0.1,
			"heavy": 0.1,
			"sky": 0.1,
			"transparent": 0.14
		}
	},
	"wave21": {
		"amount": 40,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.52,
			"fast": 0.1,
			"heavy": 0.15,
			"sky": 0.1,
			"transparent": 0.13
		}
	},
	"wave22": {
		"amount": 40,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.48,
			"fast": 0.1,
			"heavy": 0.1,
			"sky": 0.1,
			"transparent": 0.22
		}
	},
	"wave23": {
		"amount": 40,
		"interval": 3,
		"mutation_probilities": {
			"normal": 0.44,
			"fast": 0.15,
			"heavy": 0.15,
			"sky": 0.15,
			"transparent": 0.16
		}
	},
	"wave24": {
		"amount": 40,
		"interval": 2,
		"mutation_probilities": {
			"normal": 0.40,
			"fast": 0.,
			"heavy": 0.05,
			"sky": 0.25,
			"transparent": 0.25
		}
	},
	"wave25": {
		"amount": 100,
		"interval": 1.5,
		"mutation_probilities": {
			"normal": 0.2,
			"fast": 0.2,
			"heavy": 0.2,
			"sky": 0.2,
			"transparent": 0.2
		}
	}
}
const ENEMY_INFO: Dictionary = {
	"normal": {
		"damage": 1,
		"speed": 3,
		"health": 10,
		"flight_height": 8
	},
	"fast": {
		"damage": 2,
		"speed": 5,
		"health": 5,
		"flight_height": 1.7
	},
	"heavy": {
		"damage": 4,
		"speed": 2,
		"health": 25,
		"flight_height": 1.3
	},
	"sky": {
		"damage": 5,
		"speed": 3,
		"health": 15,
		"flight_height": 3
	},
	"transparent": {
		"damage": 5,
		"speed": 3,
		"health": 25,
		"flight_height": 1.3
	}
}

var damage_level: int = 0
var firerate_level: int = 0
var hp_level: int = 0
var scale_level: int = 0
var durabilty_level: int = 0

var damage: int = 1
var durability: int = 1
var bullet_scale: Vector3 = Vector3(1, 1, 1)

var coins: int = 0

var mobs_left: int
var can_spawn_enemies: bool = true
var current_wave: int = 1
var spawning_enemies: bool = false
var mob_stat_mult: int
var mutation_probabilities: Dictionary

func _lock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unlock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
