extends Control


@export var _icon: TextureRect
@export var _timer: Timer


func update(item: ItemData) -> void:
	if not _timer.is_stopped():
		_timer.stop()
	
	_icon.texture = item.icon
	_timer.start()


func _on_timer_timeout() -> void:
	hide()
