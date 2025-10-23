extends Node
# Loot tables singleton

# Database holding the loot tables
var basic_trash: Dictionary = {
	"iron": 8,
	"silicon": 2,
	"copper": 5,
	"oil": 2,
}

# Returns a dictionary of items rolled from a loot table.
func get_weighted_returns(table_name: String, rolls: int) -> Dictionary:
	var table: Dictionary = get(table_name)
	if table == null:
		push_error("Loot table '%s' not found!" % table_name)
		return {}

	var total_weight: float = 0.0
	for weight in table.values():
		total_weight += weight

	var results: Dictionary = {}

	for i in range(rolls):
		var pick = randf() * total_weight
		var cumulative = 0.0
		for key in table.keys():
			cumulative += table[key]
			if pick <= cumulative:
				results[key] = results.get(key, 0) + 1
				break
	
	return results
