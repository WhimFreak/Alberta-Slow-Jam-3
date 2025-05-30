extends Node
var pause_menu_scene : PackedScene = preload("res://UI/pause_menu.tscn")
#meant to hold a reference to the main game node
var game_scene : Node3D
var current_resolution : int
var current_window_mode : int 
var music_volume : float = 100
var sfx_volume : float = 100
var mouse_sens : float = 0.25
#handles opening the pause menu from anywhere in the game, except when there are 'nonpausablemenus' (like the main menu) open
func _input(event):
	if event.is_action_pressed("escape"):
		if get_tree().get_nodes_in_group("nonpausablemenus").is_empty():
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
			var pause_menu_node = pause_menu_scene.instantiate()
			self.add_child(pause_menu_node) 
