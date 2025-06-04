class_name EventPopup
extends Control

const NOTIFICATION_LABEL = preload("res://UI/notification_label.tscn")

@export var max_notifications: int = 5

@onready var notification_queue: VBoxContainer = $NotificationQueue

var notification_array: Array[RichTextLabel]

func _ready() -> void:
	update_queue()

func update_queue():
	if notification_array.is_empty():
		notification_queue.hide()
	else:
		notification_queue.show()

func add_notification(text: String = ""):
	var notif = NOTIFICATION_LABEL.instantiate()
	notif.text = text
	notification_array.append(notif)
	notification_queue.add_child(notif)
	update_queue()
	
	var anim: AnimationPlayer = notif.get_node("AnimationPlayer")
	anim.play("notif")
	await anim.animation_finished
	
	notification_array.erase(notif)
	notif.queue_free()
	
	
