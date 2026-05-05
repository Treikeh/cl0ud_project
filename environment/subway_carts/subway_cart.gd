extends Node3D


@export var _speed: float = 75.0
@export var _subway_cart_mesh: Node3D


func _ready() -> void:
	var roll: int = randi_range(1, 100)
	if roll > 95:
		_subway_cart_mesh.hide()


func _process(delta: float) -> void:
	global_position += -global_basis.z * delta * _speed


func _on_timer_timeout() -> void:
	queue_free()
