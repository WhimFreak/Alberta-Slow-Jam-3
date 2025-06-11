class_name NPC
extends CharacterBody3D

@export var trade_table_base: TradeTable
@export var dialogue_file : DialogueResource
@export var faces_player_on_interact: bool = false

var trade_table
var interacting: bool = false
var player_ref: CharacterBody3D

func _ready() -> void:
	trade_table = trade_table_base.duplicate()

# Code for the dialogue goes here? 
func on_interact(player: CharacterBody3D):
	player_ref = player
	interacting = true
	if not Global.animals_met.has(self):
		Global.animals_met.append(self)
		Global.check_goals()
	Global.current_trade_table = trade_table	
	Global.start_dialogue(dialogue_file)
	
func _process(delta: float) -> void:
	if interacting and faces_player_on_interact:
		var target_dir = -(global_position - player_ref.global_position)
		global_rotation.y = lerp_angle(global_rotation.y, atan2(target_dir.x, target_dir.z), 5 * delta)
	
func start_trading():
	var hud: Hud = get_tree().get_first_node_in_group("hud") as Hud
	hud.start_trading(trade_table)
	interacting = false
