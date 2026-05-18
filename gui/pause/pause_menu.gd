extends Control


signal closed


func _ready() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _resume_game() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _quit_game() -> void:
	SaveManager.save_game()
	get_tree().paused = false
	get_tree().quit()


func _open_Settings() -> void:
	hide()
	var settings_menu := SettingsMenu.create()
	get_tree().root.add_child(settings_menu)
	settings_menu.closed.connect(_on_settings_closed)


func _on_settings_closed() -> void:
	show()
