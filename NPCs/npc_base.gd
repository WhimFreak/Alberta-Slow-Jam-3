extends CharacterBody3D

@export var trade_table: TradeTable

# Code for the dialogue goes here? 
func on_interact():
	pass
	
func start_trading():
	var hud: Hud = get_tree().get_first_node_in_group("hud") as Hud
	hud.current_trade_table = trade_table
	hud.start_trading()
