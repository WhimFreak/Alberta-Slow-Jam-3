extends Control
#preloading whatever scene we want to transition to when 'start game' is clicked
var starting_scene = preload("res://test_level.tscn")
var options_menu = preload("res://UI/options_menu.tscn")

@onready var start_button: Button = %StartButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	start_button.pivot_offset = start_button.size / 2
	options_button.pivot_offset = options_button.size / 2
	quit_button.pivot_offset = quit_button.size / 2

func _on_start_button_pressed() -> void:
	#transitions to starting scene and then gets rid of the main menu
	var new_game_scene = starting_scene.instantiate()
	get_tree().root.add_child(new_game_scene)
	self.queue_free()
	pass # Replace with function body.

func _on_options_button_pressed() -> void:
	var options_menu_node = options_menu.instantiate()
	self.add_child(options_menu_node)
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

func _on_start_button_mouse_entered() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(start_button, "scale", Vector2(1.1, 1.1), 0.1)

func _on_start_button_mouse_exited() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(start_button, "scale", Vector2(1, 1), 0.1)

func _on_options_button_mouse_entered() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(options_button, "scale", Vector2(1.1, 1.1), 0.1)

func _on_options_button_mouse_exited() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(options_button, "scale", Vector2(1, 1), 0.1)

func _on_quit_button_mouse_entered() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(quit_button, "scale", Vector2(1.1, 1.1), 0.1)

func _on_quit_button_mouse_exited() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(quit_button, "scale", Vector2(1, 1), 0.1)
