extends PanelContainer
var item_resource : Resource = preload("res://UI/banana.tres")
var item_number : int = 0:
	get:
		return item_number
	set(value):
		#updates the label's value when the item number variable is changed
		item_number = value
		$MarginContainer/TextureRect/Label.text = str(value)

func _ready() -> void:
	interpret_item_resource()
	pass
	
	
func interpret_item_resource():
	if item_resource != null:
		$MarginContainer/TextureRect.texture = item_resource.texture
		if item_resource.name == null:
			item_number = 0
	pass
