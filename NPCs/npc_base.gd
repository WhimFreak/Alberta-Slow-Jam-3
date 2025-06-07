class_name NPC
extends CharacterBody3D

@export var trade_table_base: TradeTable
@export var dialogue_file : DialogueResource

var trade_table

func _ready() -> void:
	trade_table = trade_table_base.duplicate()

# Code for the dialogue goes here? 
func on_interact():
	if not Global.animals_met.has(self):
		Global.animals_met.append(self)
		Global.check_goals()
		
	Global.start_dialogue(dialogue_file)
	
func start_trading():
	var hud: Hud = get_tree().get_first_node_in_group("hud") as Hud
	hud.start_trading(trade_table)
