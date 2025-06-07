extends Node3D

@export var rest_length: float = 2 # The default length before forces are applied
@export var stiffness: float = 5 # Higher stiffness pulls the player quicker
@export var damping: float = 3 # Force lost over time

@export var arm_max_length: float = 100
@export var arm_extend_speed: float = 230
@onready var skeleton_3d: Skeleton3D = $"../Model/Monke/Armature/Skeleton3D"

@onready var player: CharacterBody3D = get_parent()
@onready var camera_3d: Camera3D = %Camera3D

@onready var left_arm_cast: ShapeCast3D = $LeftMarker/LeftArmCast

@onready var right_arm_cast: ShapeCast3D = $RightMarker/RightArmCast

@onready var left_marker: Marker3D = $LeftMarker
@onready var right_marker: Marker3D = $RightMarker

var left_target: Vector3 = Vector3.ZERO
var right_target: Vector3 = Vector3.ZERO

var left_arm_launched: bool = false
var left_arm_retracting: bool = false
var left_arm_connected: bool = false

var right_arm_launched: bool = false
var right_arm_retracting: bool = false
var right_arm_connected: bool = false

var camera_z_basis
var arm_offset: float = 1

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse") and !left_arm_launched and !left_arm_retracting and !player.is_interacting:
		left_arm_launched = true
		camera_z_basis = -camera_3d.global_transform.basis.z
		left_marker.global_position -= camera_3d.global_transform.basis.x * arm_offset
		
	if Input.is_action_just_released("left_mouse"):
		retract(true)
		
	# While attached to a branch, apply force and update arm position/rotation
	if left_arm_connected and left_target.length() != 0:
		update_arm(true)
		update_swing(delta)
		
	# 'Animating 'throwing' the arm
	if left_arm_launched and not left_arm_connected:
		var extend_dir = camera_z_basis
		left_marker.global_position += extend_dir * delta * arm_extend_speed

		left_arm_cast.force_shapecast_update()
		update_arm()
		
		# On collision, set target variable and attach to it
		if left_arm_cast.is_colliding():
			if left_arm_cast.get_collider(0).get_collision_layer_value(3) == true: # Branches will have collision layer 3
				left_target = left_arm_cast.get_collision_point(0)
				left_arm_connected = true
			else: # Retract automatically if it hits a wall
				retract(true)
			
		if skeleton_3d.global_transform.origin.distance_to(left_marker.global_position) >= arm_max_length:
			retract(true)
			
	elif left_arm_retracting:
		retract_update(delta)
	
	# Duplicated for right arm
	if Input.is_action_just_pressed("right_mouse") and !right_arm_launched and !right_arm_retracting and !player.is_interacting:
		right_arm_launched = true
		camera_z_basis = -camera_3d.global_transform.basis.z
		right_marker.global_position += camera_3d.global_transform.basis.x * arm_offset
		
	if Input.is_action_just_released("right_mouse"):
		retract(false)
	if right_arm_connected and right_target.length() != 0:
		update_arm(false)
		update_swing(delta)
		
	if right_arm_launched and not right_arm_connected:
		var extend_dir = camera_z_basis
		right_marker.global_position += extend_dir * delta * arm_extend_speed

		right_arm_cast.force_shapecast_update()
		update_arm(false)
		
		if right_arm_cast.is_colliding():
			if right_arm_cast.get_collider(0).get_collision_layer_value(3) == true:
				right_target = right_arm_cast.get_collision_point(0)
				right_arm_connected = true
			else:
				retract(false)
				
		if skeleton_3d.global_transform.origin.distance_to(right_marker.global_position) >= arm_max_length:
			retract(false)
			
	elif right_arm_retracting:
		retract_update(delta, false)
	
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
		
func retract_update(delta, is_left: bool = true):
	var bone_idx_lower
	var bone_idx_upper
	var bone_idx_ik
	var bone_idx_wrist
	if is_left:
		bone_idx_lower = skeleton_3d.find_bone("Arm_Lower.L")
		bone_idx_upper = skeleton_3d.find_bone("Arm_Upper.L")
		bone_idx_ik = skeleton_3d.find_bone("Hand_IK.L")
		bone_idx_wrist = skeleton_3d.find_bone("Wrist.L")
	else:
		bone_idx_lower = skeleton_3d.find_bone("Arm_Lower.R")
		bone_idx_upper = skeleton_3d.find_bone("Arm_Upper.R")
		bone_idx_ik = skeleton_3d.find_bone("Hand_IK.R")
		bone_idx_wrist = skeleton_3d.find_bone("Wrist.R")
	
	var all_bones_reset := false
	
	for bone_idx in [bone_idx_upper, bone_idx_lower, bone_idx_ik, bone_idx_wrist]:
		var rest_pose = skeleton_3d.get_bone_rest(bone_idx)
		var current_pose = skeleton_3d.get_bone_global_pose(bone_idx)

		var parent_idx = skeleton_3d.get_bone_parent(bone_idx)
		var parent_rest_global = Transform3D.IDENTITY
		if parent_idx != -1:
			parent_rest_global = get_bone_rest_global(parent_idx)

		var rest_global = parent_rest_global * skeleton_3d.get_bone_rest(bone_idx)
		var current_global = skeleton_3d.get_bone_global_pose(bone_idx)

		var interp = current_pose.interpolate_with(rest_global, clamp(delta * 20, 0, 1))
		skeleton_3d.set_bone_global_pose_override(bone_idx, interp, 1.0, true)

		if not interp.origin.is_equal_approx(rest_global.origin) or \
		   not interp.basis.is_equal_approx(rest_global.basis):
			all_bones_reset = false

		else:
			all_bones_reset = true
	
	# Reset arm's state once returned
	if all_bones_reset:
		if is_left:
			left_marker.global_position = skeleton_3d.global_position
			left_arm_retracting = false
			left_target = Vector3.ZERO
		else:
			right_marker.global_position = skeleton_3d.global_position
			right_arm_retracting = false
			right_target = Vector3.ZERO
		

func get_bone_rest_global(idx: int) -> Transform3D:
	if idx == -1:
		return Transform3D.IDENTITY
	var parent = skeleton_3d.get_bone_parent(idx)
	return get_bone_rest_global(parent) * skeleton_3d.get_bone_rest(idx)
	
func update_arm(is_left: bool = true):
	var bone_idx_wrist 
	if is_left:
		bone_idx_wrist = skeleton_3d.find_bone("Wrist.L")
		var left_wrist_ik = $"../Model/Monke/Armature/Skeleton3D/LeftWristIK"
		left_wrist_ik.start()
	else:
		bone_idx_wrist = skeleton_3d.find_bone("Wrist.R")
		var right_wrist_ik = $"../Model/Monke/Armature/Skeleton3D/RightWristIK"
		right_wrist_ik.start()
		
	skeleton_3d.set_bone_global_pose_override(bone_idx_wrist, Transform3D.IDENTITY, 0.0, true)
	
	var marker_pos
	var bone_idx_arm
	var bone_idx_ik
	var bone_idx_upper
	if is_left:
		if left_target.length() != 0:
			left_marker.global_position = left_target
		marker_pos = $"../Model/Monke".to_local(left_marker.global_position)
		bone_idx_arm = skeleton_3d.find_bone("Arm_Lower.L")
		bone_idx_ik = skeleton_3d.find_bone("Hand_IK.L")
		bone_idx_upper = skeleton_3d.find_bone("Arm_Upper.L")
	else:
		if right_target.length() != 0:
			right_marker.global_position = right_target
		marker_pos = $"../Model/Monke".to_local(right_marker.global_position)
		bone_idx_arm = skeleton_3d.find_bone("Arm_Lower.R")
		bone_idx_ik = skeleton_3d.find_bone("Hand_IK.R")
		bone_idx_upper = skeleton_3d.find_bone("Arm_Upper.R")
	
	var trans_arm = Transform3D(skeleton_3d.get_bone_global_pose(bone_idx_arm).basis, marker_pos)
	skeleton_3d.set_bone_pose_position(bone_idx_arm, marker_pos)
	skeleton_3d.set_bone_global_pose_override(bone_idx_arm, trans_arm, 1, true)
		
	var trans_ik = Transform3D(skeleton_3d.get_bone_global_pose(bone_idx_ik).basis, marker_pos)
	skeleton_3d.set_bone_pose_position(bone_idx_ik, marker_pos)
	skeleton_3d.set_bone_global_pose_override(bone_idx_ik, trans_ik, 1, true)

	var pos_upper = skeleton_3d.get_bone_global_pose(bone_idx_upper).origin
	var pos_lower = skeleton_3d.get_bone_global_pose(bone_idx_arm).origin

	var aim_vector = (pos_lower - pos_upper).normalized()
	
	var original_transform = skeleton_3d.get_bone_global_pose(bone_idx_upper)
	var original_basis = original_transform.basis

	var current_forward = original_basis.y
		
	# Compute the rotation that aligns current_forward to aim_vector
	var rotation_to_target = current_forward.cross(aim_vector)
	var angle = acos(clamp(current_forward.dot(aim_vector), -1.0, 1.0))

	var new_basis
	if rotation_to_target.length_squared() > 0.0001:
		var axis = rotation_to_target.normalized()
		var delta_basis = Basis(axis, angle)
		new_basis = delta_basis * original_basis
	else:
		new_basis = original_basis 

	var new_transform = Transform3D(new_basis, pos_upper)
	skeleton_3d.set_bone_global_pose_override(bone_idx_upper, new_transform, 1.0, true)
		
	
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
