class_name TradeTable
extends Resource

@export var resource_output: ItemResource
@export var trade_rate_dict: Dictionary[ItemResource, float]

func get_conversion(item: ItemResource, amount: int) -> int:
	if not trade_rate_dict.has(item):
		return 0
	
	var output: int = round(amount * trade_rate_dict[item])
	return output
