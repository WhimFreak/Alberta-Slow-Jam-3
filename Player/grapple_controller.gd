extends Node3D

@export var rest_length: float = 2 # The default length before forces are applied
@export var stiffness: float = 5 # Higher stiffness pulls the player quicker
@export var damping: float = 3 # Force lost over time

@export var arm_max_length: float = 100
@export var arm_extend_speed: float = 200

@onready var player: CharacterBody3D = get_parent()
@onready var arms: Node3D = %Arms
@onready var camera_3d: Camera3D = %Camera3D

@onready var left_arm: Node3D = %LeftArm
@onready var left_arm_cast: ShapeCast3D = %LeftArmCast
@onready var left_arm_marker: Marker3D = %LeftArmMarker

@onready var right_arm: Node3D = %RightArm
@onready var right_arm_cast: ShapeCast3D = %RightArmCast
@onready var right_arm_marker: Marker3D = %RightArmMarker

var left_target: Vector3 = Vector3.ZERO
var left_last_target: Vector3 = Vector3.ZERO
var right_target: Vector3 = Vector3.ZERO
var right_last_target: Vector3 = Vector3.ZERO

var left_arm_launched: bool = false
var left_arm_retracting: bool = false
var left_arm_connected: bool = false

var right_arm_launched: bool = false
var right_arm_retracting: bool = false
var right_arm_connected: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse") and !left_arm_launched and !left_arm_retracting:
		left_arm_launched = true
		# Arm doesn't rotate with player while thrown
		left_arm_marker.global_position = left_arm.global_position
		left_arm.top_level = true
		
	if Input.is_action_just_released("left_mouse"):
		retract(true)
		
	# While attached to a branch, apply force and update arm position/rotation
	if left_arm_connected and left_target.length() != 0:
		update_arm(true)
		update_swing(delta)
	# Saves the last target position after retracting so it animates properly
	elif left_last_target.length() != 0:
		left_arm.look_at(left_last_target)
		
	# 'Animating 'throwing' the arm
	if left_arm_launched and not left_arm_connected:
		left_arm.scale.z = min(left_arm.scale.z + delta * arm_extend_speed, arm_max_length)
		left_arm.global_position = left_arm_marker.global_position
		
		# On collision, set target variable and attach to it
		if left_arm_cast.is_colliding():
			if left_arm_cast.get_collider(0).get_collision_layer_value(3) == true: # Branches will have collision layer 3
				left_target = left_arm_cast.get_collision_point(0)
				left_last_target = left_target
				left_arm.top_level = false
				left_arm.global_position = left_arm_marker.global_position
				left_arm_connected = true
			else: # Retract automatically if it hits a wall
				retract(true)
			
		if left_arm.scale.z >= arm_max_length:
			retract(true)
			
	elif left_arm_retracting:
		left_arm.scale.z = max(left_arm.scale.z - delta * arm_extend_speed, 0.001) # Animate the arm returning
		left_arm.global_position = left_arm_marker.global_position
		if left_arm.scale.z <= 0.002: # Reset arm's state once returned
			left_arm_retracting = false
			left_arm.top_level = false
			left_arm.global_position = left_arm_marker.global_position
			left_last_target = Vector3.ZERO
			left_arm.rotation = Vector3.ZERO
	
	# Duplicated for right arm
	if Input.is_action_just_pressed("right_mouse") and !right_arm_launched and !right_arm_retracting:
		right_arm_launched = true
		right_arm_marker.global_position = right_arm.global_position
		right_arm.top_level = true
		
	if Input.is_action_just_released("right_mouse"):
		retract(false)
	if right_arm_connected and right_target.length() != 0:
		update_arm(false)
		update_swing(delta)
	elif right_last_target.length() != 0:
		right_arm.look_at(right_last_target)
		
	if right_arm_launched and not right_arm_connected:
		right_arm.scale.z = min(right_arm.scale.z + delta * arm_extend_speed, arm_max_length)
		right_arm.global_position = right_arm_marker.global_position
		
		if right_arm_cast.is_colliding():
			if right_arm_cast.get_collider(0).get_collision_layer_value(3) == true:
				right_target = right_arm_cast.get_collision_point(0)
				right_last_target = right_target
				right_arm.top_level = false
				right_arm.global_position = right_arm_marker.global_position
				right_arm_connected = true
			else:
				retract(false)
				
		if right_arm.scale.z >= arm_max_length:
			retract(false)
			
	elif right_arm_retracting:
		right_arm.scale.z = max(right_arm.scale.z - delta * arm_extend_speed, 0.001)
		right_arm.global_position = right_arm_marker.global_position
		if right_arm.scale.z <= 0.002:
			right_arm_retracting = false
			right_arm.top_level = false
			right_arm.global_position = right_arm_marker.global_position
			right_last_target = Vector3.ZERO
			right_arm.rotation = Vector3.ZERO
	
func retract(is_left: bool = true):
	if is_left:
		left_arm_launched = false
		left_arm_connected = false
		left_arm_retracting = true
	else:
		right_arm_launched = false
		right_arm_connected = false
		right_arm_retracting = true
		
	if not player.is_on_floor():
		player.has_swung = true
	
func update_arm(is_left: bool = true):
	# Attaches the arm to the target position and rotate it around it
	if is_left:
		var dist = player.global_position.distance_to(left_target)
		
		left_arm.look_at(left_target)
		left_arm.scale.z = dist
	else:
		var dist = player.global_position.distance_to(right_target)
		
		right_arm.look_at(right_target)
		right_arm.scale.z = dist
	
func update_swing(delta: float):
	# Calculate forces from both arms and apply them
	
	var left_arm_force := Vector3.ZERO
	var right_arm_force := Vector3.ZERO
	
	if left_arm_connected:
		left_arm_force = get_spring_force(left_target)
	if right_arm_connected:
		right_arm_force = get_spring_force(right_target)
	
	player.velocity += (left_arm_force + right_arm_force) * delta
	
func get_spring_force(target_pos: Vector3) -> Vector3:
	# Some math... Idk man, I just stole this from a tutorial
	var target_direction := player.global_position.direction_to(target_pos)
	var target_distance := player.global_position.distance_to(target_pos)
	
	var displacement := target_distance - rest_length
	
	var force := Vector3.ZERO
	
	if displacement > 0:
		var spring_magnitude := stiffness * displacement
		var spring_force := target_direction * spring_magnitude
		
		var velocity_dot = player.velocity.dot(target_direction)
		var damp = -damping * velocity_dot * target_direction
		
		force = spring_force + damp
	
	return force
