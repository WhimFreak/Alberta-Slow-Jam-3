class_name TradeTable
extends Resource

var relationship_levels: Dictionary = {1: {"Output Multiplier": 1.0, "Exp Required For Level": 15, "Icon": preload("res://Assets/bored.png")},
2: {"Output Multiplier": 1.5, "Exp Required For Level": 25, "Icon": preload("res://Assets/meh.png")},
3: {"Output Multiplier": 2, "Exp Required For Level": 0, "Icon": preload("res://Assets/happi.png")}}

@export var resource_output: ItemResource
@export var trade_rate_dict: Dictionary[ItemResource, float]
@export var relationship_exp: float = 0
var current_relationship: int = 1:
	set(value):
		current_relationship = clamp(value, 0, relationship_levels.size())

func get_conversion(item: ItemResource, amount: int) -> int:
	if not trade_rate_dict.has(item):
		return 0
	
	var multi: float = relationship_levels[current_relationship]["Output Multiplier"]
	var output: int = round((amount * trade_rate_dict[item]) * multi)
	return output
	
func get_exp_req() -> float:
	return relationship_levels[current_relationship]["Exp Required For Level"]
	
func get_icon() -> Texture2D:
	return relationship_levels[current_relationship]["Icon"]

func gain_exp(value: float) -> bool:
	relationship_exp += value

	var exp_req: float = relationship_levels[current_relationship]["Exp Required For Level"]
	if exp_req <= relationship_exp and current_relationship != relationship_levels.size():
		relationship_exp -= exp_req
		current_relationship += 1
		return true
		
	return false
