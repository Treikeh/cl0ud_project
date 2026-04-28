extends Control


signal succeeded
signal failed


@export var _balance_vars: FishingVariables
@export var _center: Control
@export var _cursor: Control
@export var _cursor_2: Control
@export var _border: TextureProgressBar
@export var _hit_area: TextureProgressBar
@export var _hit_area_target: Control


var player: Player
var _is_active: bool = true
var _time: float = 0.0
var _hook_distance: float
var _hit_area_rotation_direction: float = 1


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
	
	var noise_move_speed: float = _balance_vars.fish_type_move_speed_curve.sample(_hook_distance)
	_time += delta * noise_move_speed
	
	var noise_map_value: float = _balance_vars.fish_type_move_maps[Fish.Type.MAIL].get_noise_1d(_time)
	_hit_area_rotation_direction = 1.0 if noise_map_value > 0.0 else -1.0
	
	# Use hook distance to modify the rotation speed
	var rot_speed: float = _balance_vars.hit_area_move_speed_curve.sample(_hook_distance)
	_hit_area.rotation_degrees += _hit_area_rotation_direction * rot_speed * delta
	
	#TODO: Check if clamp_angle can be used here
	if _hit_area.rotation_degrees > 180.0:
		_hit_area.rotation_degrees = -179.0
	elif _hit_area.rotation_degrees < -180.0:
		_hit_area.rotation_degrees = 179.0
	
	var hit_area_size: float = _balance_vars.hit_area_size_curve.sample(_hook_distance)
	_hit_area.value = hit_area_size#30.0 + (sin(_time * 2.5) * 10.0)
	
	# Get the direction of the hit area
	var hit_area_dir: Vector2 = cursor_start.direction_to(_hit_area_target.global_position)
	var hit_area_rot: float = rad_to_deg(atan2(hit_area_dir.x, -hit_area_dir.y))
	var hit_area_offset: float = _hit_area.value
	var cursor_rotation: float = rad_to_deg(atan2(cursor_dir.x, -cursor_dir.y))
	_cursor_2.rotation_degrees = cursor_rotation
	# Check if cursor is inside the hit area
	var within_right: bool = cursor_rotation <= (hit_area_rot + hit_area_offset)
	var within_left: bool = cursor_rotation >= (hit_area_rot - hit_area_offset)
	#var within_distance: bool = cursor_distance > 25.0
	if within_right and within_left:# and within_distance:
		#_hit_area.texture_progress.gradient.set_color(1, Color.GREEN)
		_border.texture_progress.gradient.set_color(1, Color.GREEN)
		# Increase value if inside hit area
		var increase_speed: float = _balance_vars.value_increase_speed_curve.sample(_hook_distance)
		_border.value += increase_speed * delta
		if _border.value >= 100.0:
			succeeded.emit()
	else:
		#_hit_area.texture_progress.gradient.set_color(1, Color.RED)
		_border.texture_progress.gradient.set_color(1, Color.RED)
		# Decrease value if outside of hit area
		var decrease_speed: float = _balance_vars.value_decrase_speed_curve.sample(_hook_distance)
		_border.value -= decrease_speed * delta
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
	_hook_distance = _balance_vars.hook_distance_curve.sample(Globals.hook_distance)
	_hook_distance -= _balance_vars.calm_fish_upgrade_curve.sample(player.calm_fish_upgrade_level)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func end_minigame() -> void:
	# Disable minigame
	_is_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	await tween.finished
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_rotate_hit_area_timer_timeout() -> void:
	var hit_area_rot: float = randf_range(-180.0, 180.0)
	var tween: Tween = create_tween()
	tween.tween_property(_hit_area, "rotation_degrees", hit_area_rot, 0.75)
