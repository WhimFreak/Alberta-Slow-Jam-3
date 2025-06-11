extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var has_triggered: bool = false
var main_menu_scene = preload("res://UI/main_menu.tscn")

func _ready() -> void:
	remove_from_group("nonpausablemenus")
	hide()

func on_win():
	if has_triggered:
		return
		
	has_triggered = true
	get_tree().paused = true
	add_to_group("nonpausablemenus")
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	animation_player.play("popup")
	await animation_player.animation_finished
	animation_player.play("idle")

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	
	Global.game_scene.queue_free()


func _on_keep_playing_button_pressed() -> void:
	get_tree().paused = false
	hide()
