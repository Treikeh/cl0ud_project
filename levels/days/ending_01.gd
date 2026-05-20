extends Node3D


@export var _fade_color: Control


func _ready() -> void:
	Globals.day_ended.connect(_end_level)
	_fade_color.modulate = Color.TRANSPARENT


func _end_level() -> void:
	var tween: Tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(_fade_color, "modulate", Color.WHITE, 3.0)
	tween.tween_interval(0.5)
	await tween.finished
	
	LevelManager.load_level("res://gui/credits/credits.tscn")
