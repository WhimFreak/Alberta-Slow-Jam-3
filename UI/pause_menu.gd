extends Control
var main_menu_scene = preload("res://UI/main_menu.tscn")
var options_menu = preload("res://UI/options_menu.tscn")
#get rid of pause menu on pressing escape

@onready var meet_label: RichTextLabel = %MeetLabel
@onready var befriend_label: RichTextLabel = %BefriendLabel
@onready var banana_label: RichTextLabel = %BananaLabel

func _ready() -> void:
	update_quest()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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

func _on_options_button_pressed() -> void:
	var options_menu_node = options_menu.instantiate()
	self.add_child(options_menu_node)
	pass # Replace with function body.
	
func update_quest():
	if Global.animals_met.size() >= Global.animals_met_goal:
		meet_label.text = "[color=red][s]Meet animals (%s/%s)[/s][/color]" % [Global.animals_met.size(), Global.animals_met_goal]
	else:
		meet_label.text = "Meet animals (%s/%s)" % [Global.animals_met.size(), Global.animals_met_goal]
	
	if Global.animals_befriended.size() >= Global.animals_befriended_goal:
		befriend_label.text = "[color=red][s]Befriend animals (%s/%s)[/s][/color]" % [Global.animals_befriended.size(), Global.animals_befriended_goal]
	else:
		befriend_label.text = "Befriend animals (%s/%s)" % [Global.animals_befriended.size(), Global.animals_befriended_goal]
	
	var banana_count: int = 0
	
	var hud: Hud = get_tree().get_first_node_in_group("hud")
	if hud:
		for item in hud.inventory:
			if item.name == "banana":
				banana_count = hud.inventory[item]
			
	if banana_count >= Global.bananas_goal:
		banana_label.text = "[color=red][s]Gather bananas (%s/%s)[/s][/color]" % [banana_count, Global.bananas_goal]
	else:
		banana_label.text = "Gather bananas (%s/%s)" % [banana_count, Global.bananas_goal]
