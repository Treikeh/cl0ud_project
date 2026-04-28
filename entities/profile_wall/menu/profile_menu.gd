extends Control


signal closed


var _piece_inventory: Inventory


func with_data(piece_inventory: Inventory) -> Control:
	_piece_inventory = piece_inventory
	return self


func _ready() -> void:
	for item: ItemData in _piece_inventory.items:
		print(item.name)
	_open()


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()
