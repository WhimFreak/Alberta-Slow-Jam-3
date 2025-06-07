class_name Hud
extends Control

const ITEM_BUTTON = preload("res://UI/item_button.tscn")

@export var start_inventory: Dictionary[ItemResource, int]

@onready var inventory_container: HBoxContainer = $InventoryContainer
@onready var trading_container: HBoxContainer = $TradingContainer
@onready var input_panel: ItemButton = %InputPanel
@onready var output_panel: ItemButton = %OutputPanel
@onready var confirm_button: Button = %ConfirmButton
@onready var event_popup: EventPopup = $EventPopup
@onready var relationship_ui: HBoxContainer = %RelationshipUI
@onready var relationship_icon: TextureRect = %RelationshipIcon
@onready var relationship_bar: ProgressBar = %RelationshipBar

var selected_button: ItemButton:
	set(value):
		selected_button = value
		
		for button in inventory_container.get_children():
			var stylebox = StyleBoxFlat.new()
			if button == selected_button:
				stylebox.bg_color = Color.DARK_RED
			else:
				stylebox.bg_color = Color.BLACK
			button.set("theme_override_styles/panel", stylebox)

var selected_resource: ItemResource:
	set(value):
		selected_resource = value
		input_panel.item_resource = selected_resource
		
		if selected_resource:
			input_panel.pivot_offset = input_panel.size / 2
			var tween := create_tween()
			tween.tween_property(input_panel, "scale", Vector2(1.1, 1.1), 0.1)
			tween.tween_property(input_panel, "scale", Vector2.ONE, 0.1)
		
		if current_trade_table and current_trade_table.trade_rate_dict.has(selected_resource):
			output_resource = current_trade_table.resource_output
		else:
			output_resource = null

var selected_amount: int = 0:
	set(value):
		selected_amount = value
		input_panel.item_number = selected_amount
		if current_trade_table and current_trade_table.trade_rate_dict.has(selected_resource):
			output_amount = current_trade_table.get_conversion(selected_resource, selected_amount)
		else:
			output_amount = 0
			
var output_resource: ItemResource:
	set(value):
		output_resource = value
		output_panel.item_resource = output_resource
		
var output_amount: int:
	set(value):
		output_amount = value
		output_panel.item_number = output_amount

var inventory: Dictionary[ItemResource, int]
var current_trade_table: TradeTable
var selected_resource_max_amount: int = 0
		
var trading: bool = false:
	set(value):
		trading = value
		if trading:
			trading_container.show()
			relationship_ui.show()
		else:
			trading_container.hide()
			relationship_ui.hide()

func _ready() -> void:
	Global.animals_met.clear()
	Global.animals_befriended.clear()
	inventory = start_inventory.duplicate()
	update_inventory()
	trading = false
	
func update_inventory():
	# Clear hotbar
	for child in inventory_container.get_children():
		child.queue_free()
	
	# Repopulate
	for item in inventory.keys():
		if inventory[item] <= 0:
			inventory.erase(item)
			continue
				
		var item_button := ITEM_BUTTON.instantiate()
		item_button.item_resource = item
		item_button.item_number = inventory[item]
		item_button.pivot_offset = item_button.size / 2
		item_button.clickable = true
		inventory_container.add_child(item_button)
		item_button.on_click.connect(on_inventory_item_click)
			
func on_inventory_item_click(item: ItemButton, is_left_click: bool):
	selected_button = item
	if not selected_resource:
		selected_resource = item.item_resource
		selected_resource_max_amount = item.item_number
	
	# select +1 on left click, select all on right click
	if is_left_click:
		if selected_resource == item.item_resource:
			selected_amount = clamp(selected_amount + 1, 1, selected_resource_max_amount)
		else:
			selected_resource = item.item_resource
			selected_resource_max_amount = item.item_number
			selected_amount = clamp(1, 1, selected_resource_max_amount)
	else:
		if selected_resource != item.item_resource:
			selected_resource = item.item_resource
			selected_resource_max_amount = item.item_number
		selected_amount = selected_resource_max_amount

func start_trading(trade_table: TradeTable):
	current_trade_table = trade_table
	trading = true
	update_relationship()
	
func stop_trading():
	trading = false
	
	selected_button = null
	selected_resource = null
	selected_amount = 0
	Global.emit_signal("trading_stopped")
	
func _on_gui_input(event: InputEvent) -> void:
	if not trading:
		return
	if event.is_action_released("mouse_wheel_up") and selected_resource:
		selected_amount = clamp(selected_amount + 1, 1, selected_resource_max_amount)
	elif event.is_action_released("mouse_wheel_down") and selected_resource:
		selected_amount = clamp(selected_amount - 1, 1, selected_resource_max_amount)

func _on_confirm_button_pressed() -> void:
	if not trading or not output_resource or not output_amount:
		return
	
	inventory[selected_resource] -= selected_amount
	add_to_inventory(output_resource, output_amount)
	gain_exp(selected_amount)
	
	selected_button = null
	selected_resource = null
	selected_amount = 0
	
	update_inventory()
	update_relationship()

func gain_exp(amount: float):
	if current_trade_table.gain_exp(amount):
		add_to_notification_queue("[wave][rainbow]+50%[/rainbow] Trade Value[/wave]")
		if current_trade_table.current_relationship >= 3 and not Global.animals_befriended.has(current_trade_table):
			Global.animals_befriended.append(current_trade_table)
		gain_exp(0)
	
func add_to_inventory(item: ItemResource, amount: int):
	if inventory.has(item):
		inventory[item] += amount
	else:
		inventory[item] = amount
	update_inventory()

func add_to_notification_queue(text: String = ""):
	event_popup.add_notification(text)
	
func update_relationship():
	if not current_trade_table:
		return
	
	relationship_bar.max_value = current_trade_table.get_exp_req()
	relationship_bar.value = current_trade_table.relationship_exp
	relationship_icon.texture = current_trade_table.get_icon()
