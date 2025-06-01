extends CharacterBody3D

@export var trade_table: TradeTable
@export var dialogue_file : DialogueResource

# Code for the dialogue goes here? 
func on_interact():
	Global.start_dialogue(preload("res://Assets/Dialogue/test.dialogue"))
	pass
	
func start_trading():
	var hud: Hud = get_tree().get_first_node_in_group("hud") as Hud
	hud.current_trade_table = trade_table
	hud.start_trading()
