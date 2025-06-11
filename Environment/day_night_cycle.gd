extends Node3D

@export var day_length: float = 360 # in seconds
@export var start_time: float = 0.25
@export var sun_color: Gradient
@export var sun_intensity: Curve
@export var moon_color: Gradient
@export var moon_intensity: Curve
@export var sky_top_color: Gradient
@export var sky_horizon_color: Gradient

@onready var sun: DirectionalLight3D = $Sun
@onready var moon: DirectionalLight3D = $Moon
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var visual_sun: DirectionalLight3D = $VisualSun

var time: float = 0.0
var time_rate: float = 0.0
var time_offset: float = 90
var day_passed: bool = false

func _ready() -> void:
	time_rate = 1 / day_length
	time = start_time
	
func _process(delta: float) -> void:
	time += time_rate * delta
	
	if time >= 0.3 and not day_passed:
		Global.new_day.emit()
		day_passed = true
		
	if time >= 1:
		time = 0
		day_passed = false
	
	sun.rotation_degrees.x = time * 360 + time_offset
	visual_sun.rotation_degrees.x = sun.rotation_degrees.x
	sun.light_color = sun_color.sample(time)
	sun.light_energy = sun_intensity.sample(time)
	
	moon.rotation_degrees.x = time * 360 + (360 - time_offset)
	moon.light_color = moon_color.sample(time)
	moon.light_energy = moon_intensity.sample(time)
	
	world_environment.environment.sky.sky_material.set("sky_top_color", sky_top_color.sample(time))
	world_environment.environment.sky.sky_material.set("sky_horizon_color", sky_horizon_color.sample(time))
