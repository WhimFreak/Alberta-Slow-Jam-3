extends Node3D

func _ready() -> void:
	for i in get_children():
		i.global_rotation.y = randf_range(0, 360)
