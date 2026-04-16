extends Control


signal succeeded
signal failed


@export var _min_size: float = 100.0
@export var _max_size: float = 175.0
@export var _min_start_pos: float = 200.0
@export var _marker_speed: float = 600.0
@export var _background: ColorRect
@export var _hit_area: ColorRect
@export var _hit_marker: ColorRect


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("throw_hook"):
		_try_hit_area()


func _process(delta: float) -> void:
	if not visible:
		return
	
	var marker_speed: float = _marker_speed + (Globals.hook_distance * 0.1)
	_hit_marker.position.x += marker_speed * delta
	if _hit_marker.position.x >= _background.size.x:
		failed.emit()


func start_minigame() -> void:
	# Enable minigame
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	# Reset minigame
	_hit_marker.position.x = 0.0
	var max_size: float = _max_size - (Globals.hook_distance * 0.1)
	_hit_area.size.x = randf_range(_min_size, max_size)
	# Set the hit areas positoin
	const END_OFFSET: float = 10.0
	var max_pos: float = _background.size.x - _hit_area.size.x - END_OFFSET
	_hit_area.position.x = randf_range(_min_start_pos, max_pos)


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
