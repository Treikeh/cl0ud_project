extends Control


signal succeeded
signal failed


@export var _hit_area_rotation_speed: float = 50.0
@export var _min_change_dir_time: float = 1.0
@export var _max_change_dir_time: float = 3.0
## How fast the value will increase
@export var _increase_speed: float = 30.0
## How fast the value will decrease
@export var _decrease_speed: float = 20.0
@export var _center: Control
@export var _cursor: Control
@export var _border: TextureProgressBar
@export var _hit_area: TextureProgressBar
@export var _hit_area_target: Control
@export var _hit_area_timer: Timer


var player: Player
var _is_active: bool = true
var _time: float = 0.0
var _hit_area_rotation_direction: int = 1
var _rotate_hit_area: bool = true


func _process(delta: float) -> void:
	if not visible or not _is_active:
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
		# Use hook distance to modify the rotation speed
		var hook_mod: float = Globals.hook_distance * 0.1
		var rotation_speed: float = _hit_area_rotation_speed + hook_mod - player.hook_mod
		_hit_area.rotation_degrees += _hit_area_rotation_direction * rotation_speed * delta
		#TODO: Check if clamp_angle can be used here
		if _hit_area.rotation_degrees > 180.0:
			_hit_area.rotation_degrees = -179.0
		elif _hit_area.rotation_degrees < -180.0:
			_hit_area.rotation_degrees = 179.0
		_time += delta
		_hit_area.value = 30.0 + (sin(_time * 2.5) * 10.0)
	
	# Get the direction of the hit area
	var hit_area_dir: Vector2 = cursor_start.direction_to(_hit_area_target.global_position)
	var hit_area_rot: float = rad_to_deg(atan2(hit_area_dir.x, -hit_area_dir.y))
	var hit_area_offset: float = _hit_area.value
	
	var cursor_rotation: float = rad_to_deg(atan2(cursor_dir.x, -cursor_dir.y))
	var within_right: bool = cursor_rotation <= (hit_area_rot + hit_area_offset)
	var within_left: bool = cursor_rotation >= (hit_area_rot - hit_area_offset)
	var within_distance: bool = cursor_distance > 25.0
	if within_right and within_left and within_distance:
		_hit_area.texture_progress.gradient.set_color(1, Color.GREEN)
		# Increase value if inside hit area
		_border.value += _increase_speed * delta
		if _border.value >= 100.0:
			succeeded.emit()
	else:
		_hit_area.texture_progress.gradient.set_color(1, Color.RED)
		# Decrease value if outside of hit area
		var hook_mod: float = Globals.hook_distance * 0.05
		var player_hook_mod: float = player.hook_mod * 0.5
		_border.value -= (_decrease_speed + hook_mod - player_hook_mod) * delta
		if _border.value <= 0.0:
			failed.emit()


func start_minigame() -> void:
	# Enable minigame
	_is_active = true
	
	show()
	scale = Vector2.ZERO
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	
	process_mode = Node.PROCESS_MODE_INHERIT
	# Reset minigame
	_border.value = 50.0
	_hit_area.rotation_degrees = randf_range(-180.0, 180.0)
	_hit_area_timer.wait_time = get_change_dir_time()
	_hit_area_timer.start()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func end_minigame() -> void:
	# Disable minigame
	_is_active = false
	_hit_area_timer.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	await tween.finished
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_rotate_hit_area_timer_timeout() -> void:
	_rotate_hit_area = false
	
	var hit_area_rot: float = randf_range(-180.0, 180.0)
	var tween: Tween = create_tween()
	tween.tween_property(_hit_area, "rotation_degrees", hit_area_rot, 0.75)
	
	await tween.finished
	_hit_area_timer.wait_time = get_change_dir_time()
	_hit_area_timer.start()
	# Make the hit area rotate again
	_rotate_hit_area = true
	_hit_area_rotation_direction = 1 if randi() & 1 else -1


func get_change_dir_time() -> float:
	var hook_mod: float = Globals.hook_distance * 0.01
	var player_hook_mod: float = player.hook_mod * 0.1
	var max_time: float = _max_change_dir_time - hook_mod + player_hook_mod
	if max_time < _min_change_dir_time:
		max_time = _min_change_dir_time + 0.1
	
	return randf_range(_min_change_dir_time, max_time)
