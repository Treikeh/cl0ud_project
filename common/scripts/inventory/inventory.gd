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
	_load_save_data()


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
	# Convert items array into PackedByteArra
	var byte_array: PackedByteArray = var_to_bytes_with_objects(items)
	# Compress data to save space
	var compressed: PackedByteArray = byte_array.compress(COMPRESION_MODE)
	# Compress data further by encoding it as HEX
	var hex_code: String = compressed.hex_encode()
	# Add hex code to save data
	var data: Dictionary = {
		SAVE_DATA_KEY: {
			"items": hex_code,
			"currency": var_to_str(currency),
		},
	}
	return data

func _load_save_data() -> void:
	var data: Dictionary = SaveManager.get_save_data(SAVE_DATA_KEY)
	if data.is_empty():
		return
	
	# Get currency
	currency = str_to_var(data.currency)
	
	# Decode items
	# Get hex string of the items
	var items_as_hex: String = data.items
	# Decode the hex code
	var byte_array: PackedByteArray = items_as_hex.hex_decode()
	# Uncompress byte array
	var uncompressed: PackedByteArray = byte_array.decompress_dynamic(-1, COMPRESION_MODE)
	# Decode byte_array into items array
	items = bytes_to_var_with_objects(uncompressed)
	# Update first slot index
	_update_first_empty_slot_index()

#endregion
