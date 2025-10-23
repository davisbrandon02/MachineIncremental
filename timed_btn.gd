class_name TimedButton
extends Button

# Always call game manager to add things when done
@export var game_manager: GameManager
@export var time: float = 2.0
@export var var_name: String = ""
@export var change_amount: float = 1.0
@export var cost_var_name: String = ""
@export var cost_var_amount: int = 0

# If this should get from a loot table, check here
@export var gets_from_loot_table: String = ""
@export var loot_table_rolls: int = 0

# Any button that takes time before it completes.
var is_started: bool = false

func _process(delta: float) -> void:
	if is_started:
		%ProgressBar.max_value = time
		%ProgressBar.value = %Timer.time_left
	else:
		%ProgressBar.value = 0

func start():
	%Timer.stop()
	is_started = true
	%Timer.wait_time = time
	%Timer.start()
	print("%s started" % name)

func update_time(new_time: float):
	time = new_time
	%Timer.wait_time = new_time

func _on_timer_timeout() -> void:
	if var_name != "":
		game_manager.increase_var(var_name, change_amount)
	
	if gets_from_loot_table != "" and loot_table_rolls > 0:
		print("%s: Getting from loot table %s" % [name, gets_from_loot_table])
		var loot: Dictionary = LootTables.get_weighted_returns(gets_from_loot_table, loot_table_rolls)
		for i in loot.keys():
			game_manager.increase_var(i, loot[i])
	
	# Decrease cost
	if cost_var_name != "" and cost_var_amount > 0:
		game_manager.increase_var(cost_var_name, -cost_var_amount)

func _on_pressed() -> void:
	if cost_var_name in game_manager:
		if game_manager.get(cost_var_name) >= cost_var_amount:
			start()
