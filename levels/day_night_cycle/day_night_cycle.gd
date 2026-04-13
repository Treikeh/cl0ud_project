extends Node3D


@export var _minutes_in_cycle: float = 12.0

@export_group("World environment")
@export var _world_environment: WorldEnvironment
@export var _sky_top_color: GradientTexture1D
@export var _sky_horizon_color: GradientTexture1D
@export var _ground_horizon_color: GradientTexture1D
@export var _ground_bottom_color: GradientTexture1D

@export_group("Sky light")
@export var _directional_light: DirectionalLight3D
@export var _sky_light_curve: Curve
@export var _sky_light_color: GradientTexture1D


func _process(delta: float) -> void:
	# Change light rotation
	var speed: float = 360.0 / (_minutes_in_cycle * 60.0)
	_directional_light.rotation_degrees.x += speed * delta
	# Make sure the rotation stays within -180 to 180 deg
	if _directional_light.rotation_degrees.x > 180.0:
		_directional_light.rotation_degrees.x = -179.0
	if _directional_light.rotation_degrees.x < -180.0:
		_directional_light.rotation_degrees.x = 179.0
	
	
	var color_sample: int = int(_directional_light.rotation_degrees.x + 180.0)
	var color_sample_remap: float = remap(color_sample, 0.0, 360.0, 0.0, 1.0)
	
	# Change sky color
	var sky_mat: ProceduralSkyMaterial = _world_environment.environment.sky.sky_material
	sky_mat.sky_top_color = _sky_top_color.gradient.sample(color_sample_remap)
	sky_mat.sky_horizon_color = _sky_horizon_color.gradient.sample(color_sample_remap)
	sky_mat.ground_horizon_color = _ground_horizon_color.gradient.sample(color_sample_remap)
	sky_mat.ground_bottom_color = _ground_bottom_color.gradient.sample(color_sample_remap)
	
	
	# Change light intensity
	var curve_sample: float = _directional_light.rotation_degrees.x
	_directional_light.light_energy = _sky_light_curve.sample(curve_sample)
	
	# Change light color 
	var color: Color = _sky_light_color.gradient.sample(color_sample_remap)
	_directional_light.light_color = color


#region save/load

const SAVE_DATA_KEY: String = "day_night"

func get_save_data() -> Dictionary:
	var data: Dictionary = {
		SAVE_DATA_KEY: {
			"rotation_x": var_to_str(_directional_light.rotation_degrees.x)
		},
	}
	return data

func _load_save_data() -> void:
	# Load and set save data
	var data: Dictionary = SaveManager.get_save_data(SAVE_DATA_KEY)
	if data.is_empty():
		return
	
	_directional_light.rotation_degrees.x = data.rotation_x

#endregion
