extends Control

func _ready() -> void:
	#sets all the option slider/button values to their value in the Global singleton, and hides the resolution button if in full screen
	$VBoxContainer/Control3/WindowModeButton.selected = Global.current_window_mode
	if Global.current_window_mode == 1:
		$VBoxContainer/Control4.hide()
	$VBoxContainer/Control4/ResolutionButton.selected = Global.current_resolution
	$VBoxContainer/Control5/MouseSensSlider.value = Global.mouse_sens * 100
			


func _on_exit_button_pressed() -> void:
	self.queue_free()
	pass # Replace with function body.


func _on_window_mode_button_item_selected(index: int) -> void:
	#resolution button is hidden if in full screen, since you can't actually change the resolution without creating problems in godot
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$VBoxContainer/Control4.show()
		Global.current_window_mode = 0
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		$VBoxContainer/Control4.hide()
		Global.current_window_mode = 1
	pass # Replace with function body.


func _on_resolution_button_item_selected(index: int) -> void:
	match index:
		0:
			get_window().size = Vector2i(1152,648)
			Global.current_resolution = 0
		1:
			get_window().size = Vector2i(1280,720)
			Global.current_resolution = 1
		2:
			get_window().size = Vector2i(1920,1080)
			Global.current_resolution = 2
		3:
			get_window().size = Vector2i(1920,1200)
			Global.current_resolution = 3
	pass # Replace with function body.


func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.music_volume = $VBoxContainer/Control/MusicSlider.value
	pass # Replace with function body.


func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.sfx_volume = $VBoxContainer/Control2/SFXSlider.value
	pass # Replace with function body.


func _on_mouse_sens_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.mouse_sens = ($VBoxContainer/Control5/MouseSensSlider.value / 100)
	pass # Replace with function body.
