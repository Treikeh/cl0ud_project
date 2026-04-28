extends Control


signal closed
signal fish_printed(item_data: ItemData)


var _inventory: Inventory


func with_data(inventory: Inventory) -> Control:
	_inventory = inventory
	return self


func _ready() -> void:
	_open()


func _print_fish() -> void:
	fish_printed.emit(_inventory.get_slot_data(0))
	_close()


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()
