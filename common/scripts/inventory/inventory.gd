extends Node
class_name Inventory


signal item_added
signal item_removed


@export var currency: int = 0
@export var items: Array[ItemData]


var _first_empty_slot_index: int = 0

@onready var _player: Player = get_owner()


func _ready() -> void:
	_player.inventory = self


func add_item(item_data: ItemData) -> void:
	items[_first_empty_slot_index] = item_data
	item_added.emit()
	_update_first_empty_slot_index()


func remove_item(item_index: int) -> void:
	if item_index >= items.size():
		print("Item index out of range")
		return
	
	items[item_index] = null
	item_removed.emit()
	_update_first_empty_slot_index()


func get_slot_data(index: int) -> ItemData:
	return items[index]


func _update_first_empty_slot_index() -> void:
	# Get first empty slot in the inventory
	for i: int in items.size():
		if items[i] == null:
			_first_empty_slot_index = i
			return
