class_name GameManager
extends Control

# Handles all logical processing for the game
@export var hyperspeed_mode: bool = false

func _ready() -> void:
	if hyperspeed_mode:
		Engine.time_scale = 20.0

func _process(delta: float) -> void:
	# Energy core
	energy_core += energy_core_production
	energy_core -= energy_core_consumption
	
	# Updates all UI vars
	%EnergyCoreLbl.text = "Energy Core: %.1f" % energy_core
	%CorruptionLbl.text = "Memory Corruption: %s%%" % str(int(corruption_amount))
	
	%TrashLbl.text = "Trash: %s" % str(int(trash))
	%IronLbl.text = "Iron scrap: %soz" % str(int(iron))
	%CopperLbl.text = "Copper scrap: %soz" % str(int(copper))
	%SiliconLbl.text = "Silicon: %soz" % str(int(silicon))
	%OilLbl.text = "Oil: %sml" % str(oil)
	
	%SolarPanelLbl.text = "Solar panels: %s" % str(int(solar_panels))
	%ConstructSolarPanelBtn.text = "Construct solar panel (%s Silicon)" % solar_panels_silicon_cost
	
	# Unlocks stuff. Bad code lol
	if iron > 0:
		%IronContainer.visible = true
	if copper > 0:
		%CopperContainer.visible = true
	if oil > 0:
		%OilContainer.visible = true
	if silicon > 0:
		%SiliconContainer.visible = true
		%SolarPanelContainer.visible = true
	
	if iron > 20 and !disassembler_speed_upgrade_1_bought:
		%DisassemblerSpeedUpgrade1Container.visible = true
	
	if iron > 30 and !disassembler_amount_upgrade_1_bought:
		%DisassemblerAmountUpgrade1Container.visible = true

# Change a variable in this script by the amount.
func increase_var(var_name: String, amount: float):
	if var_name in self:
		var old_amount: float = get(var_name)
		var new_amount: float = get(var_name) + amount
		set(var_name, new_amount)
		print("Changed %s: %s (%s)" % [var_name, new_amount, new_amount - old_amount])

# In order
var energy_core: float = 72.0 # Your energy grid
var energy_core_production: float = 0.0
var energy_core_consumption: float = 0.0003
var corruption_amount: float = 100.0

var trash: int = 0
var trash_pickup_amt: int = 1
func _on_pickup_trash_btn_pressed() -> void:
	increase_var("trash", trash_pickup_amt)

var iron: float = 0
var copper: float = 0
var silicon: float = 0
var oil: float = 0

var solar_panels: int = 0
var solar_panels_silicon_cost: float = 10.0
var solar_panels_energy_production: float = 0.0001
func _on_construct_solar_panel_btn_pressed() -> void:
	if silicon > solar_panels_silicon_cost:
		increase_var("solar_panels", 1)
		increase_var("silicon", -solar_panels_silicon_cost)
		increase_var("energy_core_production", solar_panels_energy_production)

var disassembler_speed_upgrade_1_bought: bool = false
func _on_disassembler_speed_upgrade_1_btn_pressed() -> void:
	var btn: TimedButton = %DisassembleBtn
	btn.update_time(btn.time - 1.0)
	increase_var("iron", -20)
	disassembler_speed_upgrade_1_bought = true
	%DisassemblerSpeedUpgrade1Container.visible = false

var disassembler_amount_upgrade_1_bought: bool = false
func _on_disassembler_amount_upgrade_1_btn_pressed() -> void:
	var btn: TimedButton = %DisassembleBtn
	btn.loot_table_rolls += 5 # Double the starting loot table rolls
	btn.cost_var_amount += 1 # Increase trash cost by 1
	increase_var("iron", -30)
	disassembler_amount_upgrade_1_bought = true
	%DisassemblerAmountUpgrade1Container.visible = false
