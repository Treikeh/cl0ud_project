extends CanvasLayer


signal fadded_inn


const TWEEN_TIME: float = 1.0

@export var _label: Label
var _time_of_day: float
@onready var _control_root: Control = $Control


func _ready() -> void:
	_time_of_day = Globals.time_of_day
	_control_root.modulate = Color.TRANSPARENT
	
	await _fade_inn()
	
	fadded_inn.emit()
	
	await _change_time_dial()
	
	_fade_out()


func _process(_delta: float) -> void:
	_label.text = str(_time_of_day)


func _fade_inn() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_control_root, "modulate", Color.WHITE, TWEEN_TIME)
	await tween.finished


func _fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_control_root, "modulate", Color.TRANSPARENT, TWEEN_TIME)
	tween.tween_callback(queue_free)


func _change_time_dial() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "_time_of_day", 6.0, TWEEN_TIME)
	tween.tween_interval(0.5)
	await tween.finished
