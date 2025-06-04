extends CharacterBody3D

@export var trade_table: TradeTable
@export var dialogue_file : DialogueResource

# Code for the dialogue goes here? 
func on_interact():
	Global.start_dialogue(dialogue_file)
	
func start_trading():
	var hud: Hud = get_tree().get_first_node_in_group("hud") as Hud
	hud.start_trading(trade_table)
