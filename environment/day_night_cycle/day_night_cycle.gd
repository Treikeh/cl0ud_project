extends Node3D
class_name DayNightCycle


## At what hour the day should start
@export var day_start: float = 5.0
## How many minutes it takes to reach midnight
@export var _minutes_in_day: float = 10.0

@export_group("World environment")
@export var _world_environment: WorldEnvironment
@export var _sky_top_color: GradientTexture1D
@export var _sky_horizon_color: GradientTexture1D
@export var _ground_horizon_color: GradientTexture1D
@export var _ground_bottom_color: GradientTexture1D

@export_group("Sky light")
@export var _sun_rot: Node3D
@export var _directional_light: DirectionalLight3D
@export var _sky_light_curve: Curve
@export var _sky_light_color: GradientTexture1D

@onready var _time_of_day: float = day_start


func _ready() -> void:
	_load_save_data()


func set_time_of_day(hour: float) -> void:
	_time_of_day = hour


func get_time_of_day() -> float:
	return _time_of_day


func _process(delta: float) -> void:
	# Change time of day
	var hours_in_day: float = 24.0 - day_start
	var speed: float = hours_in_day / (_minutes_in_day * 60.0)
	# Only change the time of day when the day hasn't reached it's end
	if _time_of_day < 24.0:
		_time_of_day += speed * delta
	
	# Set rotation of light
	_sun_rot.rotation_degrees.x = _time_of_day * 15.0
	
	var color_sample: int = int(_sun_rot.rotation_degrees.x)
	var color_sample_remap: float = remap(color_sample, 0.0, 360.0, 0.0, 1.0)
	
	# Change sky color
	var sky_mat: ProceduralSkyMaterial = _world_environment.environment.sky.sky_material
	sky_mat.sky_top_color = _sky_top_color.gradient.sample(color_sample_remap)
	sky_mat.sky_horizon_color = _sky_horizon_color.gradient.sample(color_sample_remap)
	sky_mat.ground_horizon_color = _ground_horizon_color.gradient.sample(color_sample_remap)
	sky_mat.ground_bottom_color = _ground_bottom_color.gradient.sample(color_sample_remap)
	
	
	# Change light intensity
	var curve_sample: float = _sun_rot.rotation_degrees.x
	_directional_light.light_energy = _sky_light_curve.sample(curve_sample)
	
	# Change light color 
	var color: Color = _sky_light_color.gradient.sample(color_sample_remap)
	_directional_light.light_color = color


#region save/load

const SAVE_DATA_KEY: String = "day_night_cycle"

func get_save_data() -> Dictionary:
	var data: Dictionary = {
		SAVE_DATA_KEY: {
			"time_of_day": _time_of_day
		},
	}
	return data

func _load_save_data() -> void:
	# Load and set save data
	var data: Dictionary = SaveManager.get_save_data(SAVE_DATA_KEY)
	if not data.is_empty():
		_time_of_day = data.time_of_day
	
	set_time_of_day(_time_of_day)

#endregion
