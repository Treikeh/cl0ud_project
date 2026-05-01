extends Node
class_name Inventory


signal item_added
signal item_removed


@export var currency: int = 0
@export var items: Array[ItemData]


var _first_empty_slot_index: int = 0
var player: Player


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


#region save/load

const SAVE_DATA_KEY: String = "inventory"
const COMPRESION_MODE: int = FileAccess.COMPRESSION_DEFLATE

func get_save_data() -> Dictionary:
	# Get data from each item
	var items_data: Dictionary = {}
	for i: int in items.size():
		var item: ItemData = items[i]
		# Check if there is an item at the index
		if item:
			#items_data[i] = item.get_data()
			items_data[i] = item.resource_path
	
	# Set save data
	var data: Dictionary = {
		"currency": currency,
		"items": items_data,
	}
	return data

func load_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	
	# Update currency
	currency = int(data.currency)
	
	# Update items
	var items_data: Dictionary = data.items
	for key in items_data:
		# Create a new item
		#var item := ItemData.new(items_data[key])
		var item: ItemData = load(items_data[key])
		
		# Set item at the right index
		var index: int = int(key)
		items[index] = item
	
	_update_first_empty_slot_index()

#endregion
