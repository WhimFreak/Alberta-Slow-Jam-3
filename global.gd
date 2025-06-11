extends Node
var pause_menu_scene : PackedScene = preload("res://UI/pause_menu.tscn")
#meant to hold a reference to the main game node
var game_scene : Node3D
var current_resolution : int
var current_window_mode : int 
var music_volume : float = 100
var sfx_volume : float = 100
var mouse_sens : float = 0.25
var resource: DialogueResource = preload("res://Assets/Dialogue/test.dialogue")
var current_interacting_npc = null
var next_squirrel_dialogue : String = "intro"
var next_alligator_dialogue : String = "intro"
var next_fish_dialogue : String = "intro"
var already_seen_dialogue : Dictionary = {
	"secondsquirrelaffinity" : false,
	"thirdsquirrelaffinity" : false,
	"secondalligatoraffinity" : false,
	"thirdalligatoraffinity" : false,
	"secondfishaffinity" : false,
	"thirdfishaffinity" : false,
}
var current_trade_table : TradeTable
signal trading_stopped
signal new_day

@export var animals_met_goal: int = 2
@export var animals_befriended_goal: int = 2
@export var bananas_goal: int = 30

var animals_met: Array[NPC] = []
var animals_befriended: Array[TradeTable] = []

#handles opening the pause menu from anywhere in the game, except when there are 'nonpausablemenus' (like the main menu) open
func pause(): # Changed so this is called on the player script, so you can exit interaction menus without pausing
	if get_tree().get_nodes_in_group("nonpausablemenus").is_empty():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		var pause_menu_node = pause_menu_scene.instantiate()
		self.add_child(pause_menu_node) 

func check_goals():		
	var banana_count: int = 0	
	var hud: Hud = get_tree().get_first_node_in_group("hud")
	if hud:
		for item in hud.inventory:
			if item.name == "banana":
				banana_count = hud.inventory[item]
		
	if (animals_met.size() >= animals_met_goal and
	animals_befriended.size() >= animals_befriended_goal and
	banana_count >= bananas_goal):
		var win_screen = get_tree().get_first_node_in_group("win_screen")
		win_screen.on_win()

func start_dialogue(dialogue_resource):
	var title : String
	match dialogue_resource.resource_path:
		"res://Assets/Dialogue/squirrel.dialogue":
			if current_trade_table.current_relationship == 2 and already_seen_dialogue["secondsquirrelaffinity"] == false:
				next_squirrel_dialogue = "secondaffinity"
				already_seen_dialogue["secondsquirrelaffinity"] = true
			elif current_trade_table.current_relationship == 3 and already_seen_dialogue["thirdsquirrelaffinity"] == false:
				next_squirrel_dialogue = "thirdaffinity"
				already_seen_dialogue["thirdsquirrelaffinity"] = true
			title = next_squirrel_dialogue
			DialogueManager.show_dialogue_balloon(dialogue_resource, title)
			next_squirrel_dialogue = "trade"
		"res://Assets/Dialogue/alligator.dialogue":
			if current_trade_table.current_relationship == 2 and already_seen_dialogue["secondalligatoraffinity"] == false:
				next_alligator_dialogue = "secondaffinity"
				already_seen_dialogue["secondalligatoraffinity"] = true
			elif current_trade_table.current_relationship == 3 and already_seen_dialogue["thirdaffinity"] == false:
				next_alligator_dialogue = "thirdalligatoraffinity"
				already_seen_dialogue["thirdalligatoraffinity"] = true
			title = next_alligator_dialogue
			DialogueManager.show_dialogue_balloon(dialogue_resource, title)
			next_alligator_dialogue = "trade"
		"res://Assets/Dialogue/dead_fish.dialogue":
			if current_trade_table.current_relationship == 2 and already_seen_dialogue["secondfishaffinity"] == false:
				next_fish_dialogue = "secondaffinity"
				already_seen_dialogue["secondfishaffinity"] = true
			elif current_trade_table.current_relationship == 3 and already_seen_dialogue["thirdfishaffinity"] == false:
				next_fish_dialogue = "thirdaffinity"
				already_seen_dialogue["thirdfishaffinity"] = true
			title = next_fish_dialogue
			DialogueManager.show_dialogue_balloon(dialogue_resource, title)
			next_fish_dialogue = "trade"
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
