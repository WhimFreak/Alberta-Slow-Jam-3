extends Node3D

const RESOURCE = preload("res://Environment/resource.tscn")

@export var max_fruit_per_day: int = 3
@export var min_spawn_offset: float = 5
@export var max_spawn_offset: float = 10

@export var resource_chance: Dictionary[ItemResource, float]
@onready var spawn_markers: Node3D = $SpawnMarkers

func _ready():
	Global.new_day.connect(on_new_day)
	on_new_day()
	
func on_new_day():
	for i in randi_range(0, max_fruit_per_day):
		var item
		var randomizer = randf()
		for i2 in resource_chance:
			if randomizer <= resource_chance[i2]:
				item = i2
		var item_inst = RESOURCE.instantiate()
		
		if not item:
			continue
			
		item_inst.item = item
		
		var random_offset = Vector3(
			randf_range(min_spawn_offset, max_spawn_offset),
			2,
			randf_range(min_spawn_offset, max_spawn_offset)
		)
		if randf() > 0.5:
			random_offset.x = -random_offset.x
		if randf() > 0.5:
			random_offset.z = -random_offset.z
			
		var spawn_pos = $Tree.global_transform.origin + random_offset
		
		var resources = get_tree().get_first_node_in_group("resources")
		if resources:
			resources.add_to_world(item_inst)
		if item_inst:
			item_inst.global_transform.origin = spawn_pos
		
