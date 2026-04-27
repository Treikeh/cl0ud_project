extends OmniLight3D


@export var _speed: float = 50.0
@export var _min_value: float = 0.1
@export var _max_value: float = 5.0
@export var _noise_map: Noise

var _time: float

@onready var _default_energy: float = light_energy


func _process(delta: float) -> void:
	_time += delta
	var noise_value: float = _noise_map.get_noise_1d(_time * _speed) + 0.5
	noise_value = clampf(noise_value, 0.0, 1.0)
	light_energy = _default_energy * noise_value
	light_energy = clampf(light_energy, _min_value, _max_value)
