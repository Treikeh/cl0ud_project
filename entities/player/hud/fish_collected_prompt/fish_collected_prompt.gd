extends Control


@export var _icon: TextureRect
@export var _timer: Timer

@onready var default_pos: Vector2 = global_position
@onready var default_rot: float = rotation_degrees
@onready var default_scale: Vector2 = scale


func open(item: ItemData) -> void:
	show()
	scale = Vector2.ZERO
	
	_update(item)
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", default_scale, 0.1)


func close() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(hide)


func _update(item: ItemData) -> void:
	if not _timer.is_stopped():
		_timer.stop()
	
	_icon.texture = item.icon
	_timer.start()


func _on_timer_timeout() -> void:
	close()
