extends CanvasLayer


signal fadded_inn


const TWEEN_TIME: float = 1.0

@export var _label: Label
var _time_of_day: float

@onready var sun_dial: Control = $Control/SunDailRoot/SunDial
@onready var _control_root: Control = $Control


func _ready() -> void:
	_time_of_day = Globals.time_of_day
	_control_root.modulate = Color.TRANSPARENT
	
	
	await _fade_inn()
	
	fadded_inn.emit()
	
	await _change_time_dial()
	
	_fade_out()


func _process(_delta: float) -> void:
	var label_time: float = _time_of_day
	if label_time > 24.0:
		label_time -= 24.0
	_label.text = str(snappedf(label_time, 0.1))
	
	sun_dial.rotation_degrees = _time_of_day * 15.0


func _fade_inn() -> void:
	var tween: Tween = create_tween()
	tween.tween_interval(0.75)
	tween.tween_property(_control_root, "modulate", Color.WHITE, TWEEN_TIME)
	await tween.finished


func _fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_control_root, "modulate", Color.TRANSPARENT, TWEEN_TIME)
	tween.tween_callback(queue_free)


func _change_time_dial() -> void:
	const START_TIME: float = 6.0
	var hours_until_midnight: float = 24.0 - _time_of_day
	var target_time: float = _time_of_day + hours_until_midnight + START_TIME
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "_time_of_day", target_time, TWEEN_TIME)
	tween.tween_interval(0.5)
	await tween.finished
