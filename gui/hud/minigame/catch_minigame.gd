extends Control


signal succeeded
signal failed


@export var _marker_speed: float = 600.0
@export var _background: ColorRect
@export var _hit_area: ColorRect
@export var _hit_marker: ColorRect


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_hook"):
		_try_hit_area()


func _process(delta: float) -> void:
	if not visible:
		return
	
	_hit_marker.position.x += _marker_speed * delta
	if _hit_marker.position.x >= _background.size.x:
		failed.emit()


func start_minigame() -> void:
	# Enable minigame
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	# Reset minigame
	_hit_marker.position.x = 0.0
	var min_size: float = 75.0
	var max_size: float = 150.0
	_hit_area.size.x = randf_range(min_size, max_size)
	# Set the hit areas positoin
	var min_pos: float = 200.0
	var max_pos: float = _background.size.x - _hit_area.size.x - 10.0
	_hit_area.position.x = randf_range(min_pos, max_pos)


func end_minigame() -> void:
	# Disable minigame
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _try_hit_area() -> void:
	var start: float = _hit_area.position.x
	var end: float = _hit_area.position.x + _hit_area.size.x
	if _hit_marker.position.x > start and _hit_marker.position.x < end:
		succeeded.emit()
	else:
		failed.emit()
