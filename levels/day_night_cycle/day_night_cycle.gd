extends Node3D


@export var _speed: float = 10.0
@export var _world_environment: WorldEnvironment
@export var _directional_light: DirectionalLight3D
@export var _curve: Curve
@export var _color_gradient: GradientTexture1D


func _process(delta: float) -> void:
	# Change light rotation
	_directional_light.rotation_degrees.x += _speed * delta
	# Make sure the rotation stays within -180 to 180 deg
	if _directional_light.rotation_degrees.x > 180.0:
		_directional_light.rotation_degrees.x = -179.0
	if _directional_light.rotation_degrees.x < -180.0:
		_directional_light.rotation_degrees.x = 179.0
	
	# Change light intensity
	var sample: float = _directional_light.rotation_degrees.x
	_directional_light.light_energy = _curve.sample(sample)
	
	# Change light color 
	var color_sample: int = int(_directional_light.rotation_degrees.x + 180.0)
	var color: Color = _color_gradient.gradient.sample(remap(color_sample, 0.0, 360.0, 0.0, 1.0))
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
