class_name PickupResource
extends RigidBody3D

@export var item: ItemResource

@onready var model: Node3D = $Model

func _ready() -> void:
	var model_inst = item.model.instantiate()
	model_inst.position = Vector3.ZERO
	model_inst.scale = Vector3(1.5, 1.5, 1.5)
	model.add_child(model_inst)

func on_collect():
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		return
	
	hud.add_to_inventory(item, 1)
	queue_free()
