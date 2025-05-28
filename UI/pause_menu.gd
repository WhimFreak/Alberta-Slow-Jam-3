extends Control
var main_menu_scene = preload("res://UI/main_menu.tscn")
#get rid of pause menu on pressing escape
func _input(event):
	if event.is_action_pressed("escape"):
		get_tree().paused = false
		self.queue_free()

#get rid of game scene and pause menu when hitting main menu button
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	var new_game_scene = main_menu_scene.instantiate()
	get_tree().root.add_child(new_game_scene)
	get_tree().paused = false
	Global.game_scene.queue_free()
	self.queue_free()
	pass # Replace with function body.
