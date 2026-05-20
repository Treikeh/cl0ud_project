extends CanvasLayer


signal fadded_inn


const TWEEN_TIME: float = 1.0

@export var _day_label: Label
@export var _label: Label

var _time_of_day: float
var _current_day: int = 1

@onready var sun_dial: Control = $Control/SunDailRoot/SunDial
@onready var _control_root: Control = $Control


func with_data(current_day: int) -> CanvasLayer:
	_current_day = current_day
	return self


func _ready() -> void:
	_time_of_day = Globals.time_of_day
	_control_root.modulate = Color.TRANSPARENT
	
	_day_label.text = "DAY 0" + str(_current_day)
	
	
	await _fade_inn()
	
	fadded_inn.emit()
	
	await _change_time_dial()
	
	_fade_out()


func _process(_delta: float) -> void:
	var label_time: float = _time_of_day
	if label_time > 24.0:
		label_time -= 24.0
	
	var hour := int(label_time)
	var text: String = str(hour) + ":00"
	if not text.begins_with("1") and not text.begins_with("2"):
		text = "0" + text
	_label.text = text
	
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
	
	var day_tween: Tween = create_tween().chain()
	_day_label.text = "DAY ab"
	day_tween.tween_property(_day_label, "text", "DAY 0" + str(_current_day + 1), TWEEN_TIME)
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "_time_of_day", target_time, TWEEN_TIME)
	tween.tween_interval(0.5)
	await tween.finished
