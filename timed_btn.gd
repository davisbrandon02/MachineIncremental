class_name TimedButton
extends Button

# Any button that takes time before it completes.

# Always call game manager to add things when done
@export var game_manager: GameManager
@export var time: float = 2.0
@export var amount: int = 1
@export var changes: Dictionary[String, float]
@export var costs: Dictionary[String, float]

# If this should get from a loot table, check here
@export var gets_from_loot_table: String = ""
@export var loot_table_rolls: int = 0

@export var can_run: bool = false
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
	if changes.size() > 0:
		for key in changes:
			if game_manager.has(key):
				game_manager.increase_var(key, changes[key] * amount)
	
	if gets_from_loot_table != "" and loot_table_rolls > 0:
		print("%s: Getting from loot table %s" % [name, gets_from_loot_table])
		var loot: Dictionary = LootTables.get_weighted_returns(gets_from_loot_table, loot_table_rolls * amount)
		game_manager.increase_vars_from_dict(loot)
	
	# Decrease cost items by amount
	if costs.size() > 0:
		for key in costs:
			if key in game_manager:
				game_manager.increase_var(key, -costs[key] * amount)

func _on_pressed() -> void:
	if can_run and game_manager.costs_met(costs, amount) and amount > 0:
		start()
