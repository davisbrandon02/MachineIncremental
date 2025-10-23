class_name GameManager
extends Control

# Handles all logical processing for the game
@export var hyperspeed_mode: bool = false

func _ready() -> void:
	if hyperspeed_mode:
		Engine.time_scale = 100.0
	for i in %VBoxContainer.get_children():
		# Hide all containers except trash container
		if i.name.contains("Container") and i.name != "TrashContainer":
			i.visible = false

func _process(delta: float) -> void:
	# Energy core
	energy_core += energy_core_production
	energy_core -= energy_core_consumption
	
	# Updates all UI vars
	%EnergyCoreLbl.text = "Energy Core: %.1f" % energy_core
	%CorruptionLbl.text = "Memory Corruption: %s%%" % str(int(corruption_amount))
	
	%TrashLbl.text = "Trash: %s" % str(int(trash))
	%ScrapMetalLbl.text = "Scrap metal: %soz" % str(int(scrap_metal))
	%PlasticLbl.text = "Plastic: %soz" % str(int(plastic))
	%WiresLbl.text = "Wires: %scm" % str(int(wires))
	%OilLbl.text = "Oil: %sml" % str(oil)
	%SmelterLbl.text = "Smelters: %s" % str(int(smelters))
	%ConstructSmelterBtn.text = "Build smelter (%s)" % get_dict_as_string(smelter_costs)
	%MetalBarsLbl.text = "Metal bars: %s" % str(int(metal_bars))
	%DisassemblerSpeedUpgradeBtn.text = "Disassembler speed upgrade %s (%s)" % [disassembler_speed_upgrade_amount_bought + 1, get_dict_as_string(disassembler_speed_upgrade_costs)]
	%DisassemblerSpeedUpgradeBtn.text = "Disassembler amount upgrade %s (%s)" % [disassembler_speed_upgrade_amount_bought + 1, get_dict_as_string(disassembler_speed_upgrade_costs)]
	
	# Unlocks stuff. Bad code lol
	if scrap_metal > 0:
		%ScrapMetalContainer.visible = true
	if plastic > 0:
		%PlasticContainer.visible = true
	if oil > 0:
		%OilContainer.visible = true
	if wires > 0:
		%WiresContainer.visible = true
	
	if costs_met(smelter_costs):
		%SmelterContainer.visible = true
	if metal_bars > 0:
		%MetalBarsContainer.visible = true
	
	if metal_bars > 20 and !disassembler_speed_upgrade_amount_bought > 0:
		%DisassemblerSpeedUpgradeContainer.visible = true
	
	if metal_bars > 30 and !disassembler_amount_upgrade_amount_bought > 0:
		%DisassemblerAmountUpgradeContainer.visible = true

#region Helper functions
# Increase by all vars in a dictionary
func increase_vars_from_dict(dict: Dictionary):
	for key in dict:
		increase_var(key, float(dict[key]))

# Return multiplied dictionary
func multiply_dict(original_dict: Dictionary, mult: float):
	var new_dict := {}
	for key in original_dict:
		new_dict[key] = original_dict[key] * mult
	return new_dict

# Change a variable in this script by the amount.
func increase_var(var_name: String, amount: float):
	if var_name in self:
		var old_amount: float = get(var_name)
		var new_amount: float = get(var_name) + amount
		set(var_name, new_amount)
		print("Changed %s: %s (%s)" % [var_name, new_amount, new_amount - old_amount])
	else:
		print_rich('[color=red]ERROR: Tried to increase var %s by %s but not found[/color]' % [var_name, amount])


func has(var_name: String):
	var val = var_name in self
	return val

func get_dict_as_string(dict: Dictionary) -> String:
	var parts: Array[String] = []
	for key in dict.keys():
		var amount = abs(dict[key])
		var item_name = key.replace("_", " ")  # Replace underscores with spaces
		parts.append("%s %s" % [amount, item_name])
	return ", ".join(parts)

# Take in a dictionary of costs and see if we have enough
func costs_met(cost_dict: Dictionary, multiplied_by: float = 1):
	var met: bool = true
	for var_name in cost_dict.keys():
		if var_name in self:
			# Get absolute because costs are negative
			var cost = float(abs(cost_dict[var_name])) * multiplied_by
			var stored_amount = float(get(var_name))
			if stored_amount < cost:
				met = false
	return met
#endregion

# In order
var energy_core: float = 72.0 # Your energy grid
var energy_core_production: float = 0.0
var energy_core_consumption: float = 0.0003
var corruption_amount: float = 100.0

var trash: int = 0
var trash_pickup_amt: int = 1
func _on_pickup_trash_btn_pressed() -> void:
	increase_var("trash", trash_pickup_amt)

# Refined materials
var metal_bars: float = 0

# Scrap from trash
var plastic: float = 0
var scrap_metal: float = 0
var wires: float = 0
var oil: float = 0

# Early upgrades for disassembler.
var disassembler_speed_upgrade_costs = {"metal_bar": -20}
var disassembler_speed_upgrade_amount_bought: int = 0
func _on_disassembler_speed_upgrade_btn_pressed() -> void:
	var btn: TimedButton = %SortBtn
	btn.update_time(btn.time - 1.0)
	increase_vars_from_dict(disassembler_amount_upgrade_costs)
	disassembler_speed_upgrade_amount_bought += 1
	%DisassemblerSpeedUpgrade1Container.visible = false

var disassembler_amount_upgrade_costs = {"metal_bar": -30}
var disassembler_amount_upgrade_amount_bought: int = 0
func _on_disassembler_amount_upgrade_btn_pressed() -> void:
	var btn: TimedButton = %SortBtn
	btn.loot_table_rolls += 5 # Double the starting loot table rolls
	btn.cost_var_amount += 1 # Increase trash cost by 1
	increase_vars_from_dict(disassembler_amount_upgrade_costs)
	disassembler_amount_upgrade_amount_bought += 1

# Smelters. Create metal bars from scrap using oil
var smelters: int = 0
var smelter_costs = {
	"scrap_metal": -30,
	"wires": -5,
}
func _on_construct_smelter_btn_pressed() -> void:
	%SmeltBtn.can_run = true
	if costs_met(smelter_costs):
		smelters += 1
		%SmeltBtn.amount += 1
		smelter_costs = multiply_dict(smelter_costs, 1.25)
		increase_vars_from_dict(smelter_costs)
