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
@export_group("SFX")
@export var _succeeded_sfx: FmodEventEmitter2D
@export var _failed_sfx: FmodEventEmitter2D

var player: Player
var _is_active: bool = true


func _input(event: InputEvent) -> void:
	if not visible or not _is_active:
		return
	
	if event.is_action_pressed("throw_hook"):
		_try_hit_area()


func _process(delta: float) -> void:
	if not visible or not _is_active:
		return
	
	var hook_mod: float = Globals.hook_distance * 0.1
	var marker_speed: float = _marker_speed + hook_mod - player.hook_mod
	_hit_marker.position.x += marker_speed * delta
	if _hit_marker.position.x >= _background.size.x:
		_is_active = false
		_failed_sfx.play_one_shot()
		failed.emit()


func start_minigame() -> void:
	# Enable minigame
	show()
	_is_active = true
	process_mode = Node.PROCESS_MODE_INHERIT
	# Reset minigame
	_hit_marker.position.x = 0.0
	var hook_mod: float = Globals.hook_distance * 0.1
	var max_size: float = _max_size - hook_mod + player.hook_mod
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
	_is_active = false
	var start: float = _hit_area.position.x
	var end: float = _hit_area.position.x + _hit_area.size.x
	if _hit_marker.position.x > start and _hit_marker.position.x < end:
		_succeeded_sfx.play_one_shot()
		_hit_marker.color = Color.GREEN
		
		var tween: Tween = create_tween()
		tween.set_parallel(false)
		tween.tween_property(_hit_marker, "scale", Vector2.ONE * 1.5, 0.1)
		tween.tween_property(_hit_marker, "scale", Vector2.ONE * 1, 0.1)
		tween.tween_interval(0.5)
		tween.tween_callback(succeeded.emit)
	else:
		_failed_sfx.play_one_shot()
		_hit_marker.color = Color.RED
		
		var tween: Tween = create_tween()
		tween.set_parallel(false)
		tween.tween_property(_hit_marker, "scale", Vector2.ONE * 1.5, 0.1)
		tween.tween_property(_hit_marker, "scale", Vector2.ONE * 1, 0.1)
		tween.tween_interval(0.5)
		tween.tween_callback(failed.emit)
