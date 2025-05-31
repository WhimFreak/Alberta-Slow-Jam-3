extends CharacterBody3D

@export var mouse_sensitivity: float = 0.25
@export var walk_speed: float = 15
@export var acceleration: float = 70
@export var launched_deceleration: float = 15
@export var rotation_speed: float = 8
@export var jump_height: float = 14
@export var gravity: float = -35
@export var momentum_drag: float = 0.98
@export var air_control: float = 30
@export var climb_speed: float = 6
@export var climb_jump_height: float = 9

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = %Camera3D
@onready var model: Node3D = $Model
@onready var swing_controller: Node3D = $SwingController
@onready var arms: Node3D = %Arms
@onready var climb_cast: RayCast3D = %ClimbCast
@onready var pull_up_cast: RayCast3D = %PullUpCast
@onready var climb_cooldown: Timer = $ClimbCooldown
@onready var stick_holder: Marker3D = %StickHolder 
@onready var stick_point: Marker3D = %StickPoint

var camera_direction: Vector3 = Vector3.ZERO
var last_move_direction: Vector3 = Vector3.ZERO
var has_swung: bool = false
var can_climb: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.game_scene = get_parent()
	
func _unhandled_input(event: InputEvent) -> void: # Camera controls
	if event.is_action_pressed("left_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, -80, 90)
		arms.rotation_degrees = camera_pivot.rotation_degrees
		
func _physics_process(delta: float) -> void:
	camera_direction = Vector3.ZERO
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Make input directions depend on camera
	var camera_forward := camera_3d.global_basis.z
	var camera_right := camera_3d.global_basis.x
	var move_direction = (camera_forward * input.y + camera_right * input.x)
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	if swing_controller.left_arm_connected or swing_controller.right_arm_connected: # Movement while swinging
		velocity.x += move_direction.x * 30 * delta
		velocity.z += move_direction.z * 30 * delta
		if Input.is_action_just_pressed("jump"): # Player can jump while swinging for a slight vertical boost
			velocity.y += jump_height
			swing_controller.retract(true)
			swing_controller.retract(false)
	elif climb_cast.is_colliding() and can_climb:
		climb(delta)
	elif has_swung:
		post_swing_movement(move_direction, delta) # For conserving momentum
	else:
		normal_movement(move_direction, delta)
	
	move_and_slide()
	
	if is_on_floor():
		has_swung = false
	
	if move_direction.length() != 0:
		last_move_direction = move_direction
		
func normal_movement(move_dir: Vector3, delta):
	velocity.x = move_toward(velocity.x, move_dir.x * walk_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_dir.z * walk_speed, acceleration * delta)
	velocity.y += gravity * delta
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_height
	
	# Player rotates to face movement direction
	var facing_angle := Vector3.FORWARD.signed_angle_to(last_move_direction, Vector3.UP)	
	model.global_rotation.y = lerp_angle(model.global_rotation.y, facing_angle, rotation_speed * delta)

func post_swing_movement(move_dir: Vector3, delta):
	velocity.x += move_dir.x * air_control * delta
	velocity.z += move_dir.z * air_control * delta
	
	velocity.x *= momentum_drag
	velocity.z *= momentum_drag
	
	velocity.y += gravity * delta
	
	var facing_angle := Vector3.FORWARD.signed_angle_to(last_move_direction, Vector3.UP)	
	model.global_rotation.y = lerp_angle(model.global_rotation.y, facing_angle, rotation_speed * delta)
	
func climb(delta):
	# Sticks player to the wall to prevent falling off
	stick_holder.global_transform.origin = climb_cast.get_collision_point()
	global_transform.origin.x = stick_point.global_transform.origin.x
	global_transform.origin.z = stick_point.global_transform.origin.z
	
	# Move relative to the wall's normal
	var rot := -(atan2(climb_cast.get_collision_normal().z, climb_cast.get_collision_normal().x) - PI / 2)
	var forward := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var horizontal := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity = Vector3(horizontal, forward, 0).rotated(Vector3.UP, rot).normalized() * climb_speed
	
	# Rotates player towards wall
	model.global_rotation.y = rot
	
	if Input.is_action_just_pressed("jump") or not pull_up_cast.is_colliding():
		can_climb = false
		climb_cooldown.start()
		velocity.y += climb_jump_height

func _on_climb_cooldown_timeout() -> void:
	can_climb = true
