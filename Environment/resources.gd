extends Node3D

func add_to_world(item):
	if get_children().size() < 75:
		add_child(item)
	else:
		item.queue_free()
