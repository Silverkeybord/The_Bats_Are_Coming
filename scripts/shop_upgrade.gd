extends PanelContainer

const COST_TEXT: String = "Cost: "
const VALUE_TEXT: String = "Value: "
const ARROW: String = " > "
const MAX_LEVEL: String = "Max Level :O"
const LOAD_BUFFER: float = 0.5

var level: int
var time_passed: float

@export var upgrade: String
@export var upgrade_name: String = "ERROR"
@export var cost: String = "-1"
@export var value: String = "-1"

@export var upgrade_button: Button
@export var name_label : Label
@export var cost_lable : Label
@export var value_lable : Label


# Called when the node enters the scene tree for the first time.
func load_initial_values() -> void:
	level = Global.shop_upgrades[upgrade]
	name_label.text = upgrade_name
	
	
	if level == Global.SHOP_INFO[upgrade]["levels"]:
		upgrade_button.disabled = true
		cost_lable.text = MAX_LEVEL
		
	else:
		var initial_cost = str(Global.SHOP_INFO[upgrade]["cost"][str(level + 1)])
		cost_lable.text = COST_TEXT + initial_cost
	
	
	var initial_value = str(Global.SHOP_INFO[upgrade]["value"][str(level)])
	value_lable.text = VALUE_TEXT + initial_value


func _process(delta: float) -> void:
	time_passed += delta
	if time_passed >= LOAD_BUFFER:
		load_initial_values()
		set_process(false)


func upgraded() -> void:
	cost_lable.text = cost
	value_lable.text = value


func _on_upgrade_button_pressed() -> void:
	var info = Global.SHOP_INFO[upgrade]
	var upgrade_cost = info["cost"][str(level + 1)]
	
	if Global.coins < upgrade_cost:
		return
	
	Global.coins -= upgrade_cost
	level += 1
	Global.shop_upgrades[upgrade] = level
	
	if level == info["levels"]:
		cost = MAX_LEVEL
		upgrade_button.disabled = true
		value = VALUE_TEXT + str(info["value"][str(level)])
		
	else:
		cost = COST_TEXT + str(info["cost"][str(level + 1)])
		var current_value = str(info["value"][str(level)])
		var next_value = str(info["value"][str(level + 1)])
		value = VALUE_TEXT + current_value + ARROW + next_value
	
	upgraded()
