extends Control
#preloading whatever scene we want to transition to when 'start game' is clicked
var starting_scene = preload("res://test_level.tscn")
var options_menu = preload("res://UI/options_menu.tscn")

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
