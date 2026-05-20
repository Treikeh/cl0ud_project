extends Control


@export var _fade_thing: Control


func _ready() -> void:
	_fade_thing.modulate = Color.WHITE
	var tween: Tween = create_tween()
	tween.tween_property(_fade_thing, "modulate", Color.TRANSPARENT, 3.0)
	await tween.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_meta_clicked(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at runtime.
	OS.shell_open(str(meta))


func _on_quit_button_pressed() -> void:
	get_tree().quit()
