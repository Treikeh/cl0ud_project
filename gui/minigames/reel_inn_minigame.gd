extends Control


signal succeeded
signal failed


@export var _hit_area_rotation_speed: float = 50.0
@export var _increase_speed: float = 30.0
@export var _decrease_speed: float = 20.0
@export var _center: Control
@export var _cursor: Control
@export var _border: TextureProgressBar
@export var _hit_area: TextureProgressBar
@export var _hit_area_target: Control
@export var _hit_area_timer: Timer

var player: Player
var _hit_area_rotation_direction: int = 1
var _rotate_hit_area: bool = true


func _process(delta: float) -> void:
	if not visible:
		return
	
	# Set the position of the cursor
	var cursor_start: Vector2 = _center.position
	var cursor_end: Vector2 = get_global_mouse_position()
	var cursor_dir: Vector2 = cursor_start.direction_to(cursor_end)
	var cursor_distance: float = cursor_start.distance_to(cursor_end)
	cursor_distance = clampf(cursor_distance, 0.0, 175.0)
	
	_cursor.position = cursor_start + (cursor_dir * cursor_distance) - (_cursor.size / 2.0)
	# Get the rotation of the cursor from the center of the minigame
	var look_dir: Vector2 = (cursor_dir * remap(cursor_distance, 0.0, 100.0, 0.0, 1.0)) / 7.5
	player.update_minigame_look_dir(look_dir)
	
	# Rotate hit area
	if _rotate_hit_area:
		_hit_area.rotation_degrees += _hit_area_rotation_direction * _hit_area_rotation_speed * delta
		#TODO: Check if clamp_angle can be used here
		if _hit_area.rotation_degrees > 180.0:
			_hit_area.rotation_degrees = -179.0
		elif _hit_area.rotation_degrees < -180.0:
			_hit_area.rotation_degrees = 179.0
	
	# Get the direction of the hit area
	var hit_area_dir: Vector2 = cursor_start.direction_to(_hit_area_target.global_position)
	var hit_area_rot: float = rad_to_deg(atan2(hit_area_dir.x, -hit_area_dir.y))
	var hit_area_offset: float = _hit_area.value
	
	var cursor_rotation: float = rad_to_deg(atan2(cursor_dir.x, -cursor_dir.y))
	if cursor_rotation >= (hit_area_rot - hit_area_offset) and cursor_rotation <= (hit_area_rot + hit_area_offset):
		# Increase value if inside hit area
		_border.value += _increase_speed * delta
		if _border.value >= 100.0:
			succeeded.emit()
	else:
		# Decrease value if outside of hit area
		_border.value -= _decrease_speed * delta
		if _border.value <= 0.0:
			failed.emit()


func start_minigame() -> void:
	# Enable minigame
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	# Reset minigame
	_border.value = 50.0
	_hit_area.rotation_degrees = randf_range(-180.0, 180.0)
	_hit_area_timer.wait_time = randf_range(1.0, 2.0)
	_hit_area_timer.start()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func end_minigame() -> void:
	# Disable minigame
	_hit_area_timer.stop()
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_rotate_hit_area_timer_timeout() -> void:
	_rotate_hit_area = false
	
	var hit_area_rot: float = randf_range(-180.0, 180.0)
	var tween: Tween = create_tween()
	tween.tween_property(_hit_area, "rotation_degrees", hit_area_rot, 0.75)
	
	await tween.finished
	_hit_area_timer.wait_time = randf_range(1.0, 2.0)
	_hit_area_timer.start()
	# Make the hit area rotate again
	_rotate_hit_area = true
	_hit_area_rotation_direction = 1 if randi() & 1 else -1
