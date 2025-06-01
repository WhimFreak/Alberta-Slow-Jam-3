class_name ItemButton
extends PanelContainer

signal on_click(item: ItemButton, is_left: bool)

var clickable: bool = false

@export var item_resource : ItemResource:
	set(value):
		item_resource = value
		interpret_item_resource()
@export var item_number : int = 0:
	get:
		return item_number
	set(value):
		#updates the label's value when the item number variable is changed
		item_number = value
		$MarginContainer/TextureRect/Label.text = str(value)

func _ready() -> void:
	item_number = item_number
	pass
	
func interpret_item_resource():
	if item_resource != null:
		$MarginContainer/TextureRect.texture = item_resource.texture
		if item_resource.name == null:
			item_number = 0
	else:
		$MarginContainer/TextureRect.texture = null

func _on_gui_input(event: InputEvent) -> void:
	if not clickable:
		return
		
	if event.is_action_pressed("left_mouse"):
		on_click.emit(self, true)
	elif event.is_action_pressed("right_mouse"):
		on_click.emit(self, false)

func _on_mouse_entered() -> void:
	if not clickable:
		return
		
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func _on_mouse_exited() -> void:
	if not clickable:
		return
		
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
