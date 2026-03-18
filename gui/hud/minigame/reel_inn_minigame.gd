extends Control


signal succeeded
signal failed


const SLICE_SCENE: PackedScene = preload("res://gui/hud/minigame/minigame_slice.tscn")


@export var _max_lives: int = 3
@export var _required_hits: int = 5
@export var _center: Control
@export var _cursor: Control
@export var _border: TextureProgressBar
@export var _slice_root: Control
@export var _lives_container: HBoxContainer

var _lives: int
var _successful_hits: int = 0


func _process(_delta: float) -> void:
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
	Globals.minigame_look_dir = (cursor_dir * remap(cursor_distance, 0.0, 100.0, 0.0, 1.0)) / 10.0
	#cursor_rotation = rad_to_deg(atan2(cursor_dir.x, -cursor_dir.y))


func start_minigame() -> void:
	# Enable minigame
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	# Reset minigame
	_lives = 0
	_successful_hits = 0
	_border.value = 0
	_border.max_value = _required_hits
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	# Reset health bars
	for child: ColorRect in _lives_container.get_children():
		child.color = Color.WHITE
	
	# Spawn the first slice
	_spawn_slice()


func end_minigame() -> void:
	# Remove all slices
	for child: Control in _slice_root.get_children():
		_slice_root.remove_child(child)
		child.queue_free()
	# Disable minigame
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _spawn_slice() -> void:
	var center_pos: Vector2 = _center.global_position
	var spawn_dir: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	var slice: Control = SLICE_SCENE.instantiate().with_data(center_pos)
	_slice_root.add_child(slice)
	slice.global_position = center_pos + (spawn_dir * 400.0)
	
	slice.hit.connect(_hit_slice)
	slice.missed.connect(_missed_slice)


func _hit_slice() -> void:
	# Increase the hit
	_successful_hits += 1
	_border.value = float(_successful_hits)
	if _successful_hits >= _required_hits:
		succeeded.emit()
	else:
		_spawn_slice()


func _missed_slice() -> void:
	# Lives goes in reverse order so that it's easeir to change the children of the lives container
	_lives_container.get_child(_lives).color = Color.BLACK
	_lives += 1
	if _lives >= _max_lives:
		failed.emit()
	else:
		_spawn_slice()
