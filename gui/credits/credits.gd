extends Control


func _on_meta_clicked(meta):
	# `meta` is not guaranteed to be a String, so convert it to a String
	# to avoid script errors at runtime.
	OS.shell_open(str(meta))


func _on_quit_button_pressed() -> void:
	get_tree().quit()
