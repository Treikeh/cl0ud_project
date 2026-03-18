extends Control


signal hit
signal missed


@export var _move_speed: float = 150.0
var _center_pos: Vector2
var _cursor_rot: float = 0.0


func with_data(center_pos: Vector2) -> Control:
	_center_pos = center_pos
	return self


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_hook"):
		_try_hit()


func _process(delta: float) -> void:
	# Move slice towards the center
	var start: Vector2 = _center_pos
	var end: Vector2 = global_position
	var dir: Vector2 = start.direction_to(end)
	var distance: float = start.distance_to(end)
	
	# Set rotation of slice
	rotation_degrees = rad_to_deg(atan2(dir.x, -dir.y))
	# Move slice towards center
	global_position -= dir * _move_speed * delta
	
	# Scale slice based on distance to center
	var distance_scale: float = remap(distance, 400.0, 0.0, 2.0, 0.25)
	scale = Vector2.ONE * distance_scale
	
	if distance <= 10.0:
		missed.emit()
		queue_free()
	
	# Set the position of the cursor
	var cursor_start: Vector2 = _center_pos
	var cursor_end: Vector2 = get_global_mouse_position()
	var cursor_dir: Vector2 = cursor_start.direction_to(cursor_end)
	
	# Get the rotation of the cursor from the center of the minigame
	_cursor_rot = rad_to_deg(atan2(cursor_dir.x, -cursor_dir.y))


func _try_hit() -> void:
	var min_rot: float = rotation_degrees - 50.0
	var max_rot: float = rotation_degrees + 50.0
	if _cursor_rot > min_rot and _cursor_rot < max_rot:
		hit.emit()
		queue_free()
	#else:
	#	missed.emit()
	#	queue_free()
