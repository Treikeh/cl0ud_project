extends SpotLight3D


@export var _start_on: bool = true
@export var _turn_on_time: float = 22.0
@export var _turn_off_time: float = 5.0
@export var _turn_on_duration: float = 0.1
@export var _turn_off_duration: float = 0.1
## Tween ease type when turning light on/off
@export var _turn_on_off_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
## Tween transition type when turning light on/off
@export var _turn_on_off_trans: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR

var _is_on: bool = true
var _light_energy: float = 1.0


func _ready() -> void:
	_light_energy = light_energy
	if not _start_on:
		light_energy = 0.0


func _process(_delta: float) -> void:
	var time: float = Globals.time_of_day
	if time > _turn_off_time and time < _turn_on_time and _is_on:
		_is_on = false
		var tween: Tween = create_tween().set_ease(_turn_on_off_ease).set_trans(_turn_on_off_trans)
		tween.tween_property(self, "light_energy", 0.0, _turn_off_duration)
	
	if time > _turn_on_time and not _is_on:
		_is_on = true
		var tween: Tween = create_tween().set_ease(_turn_on_off_ease).set_trans(_turn_on_off_trans)
		tween.tween_property(self, "light_energy", _light_energy, _turn_on_duration)
