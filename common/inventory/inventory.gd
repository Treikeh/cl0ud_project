extends Node
class_name Inventory


signal updated


@export var items: Array[ItemData]

var _current_item_index: int = 0


func add_item(item_data: ItemData) -> void:
	set_slot(_current_item_index, item_data)
	_current_item_index += 1


func set_slot(index: int, data: ItemData) -> void:
	items[index] = data
	updated.emit()


func get_slot(index: int) -> ItemData:
	return items[index]
