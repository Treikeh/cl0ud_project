extends Node


const FILE_NAME: String = "save.ini"

var _save_data: Dictionary = {}

@onready var _file_path: String = Globals.get_data_dir() + FILE_NAME


func _ready() -> void:
	_load_data_from_file()

func _exit_tree() -> void:
	_save_data_to_file()


func set_save_data(key: String, data: Dictionary) -> void:
	_save_data[key] = data


func get_save_data(key: String) -> Dictionary:
	return _save_data[key] if _save_data.has(key) else {}


func save_game() -> void:
	var persistent_nodes: Array = get_tree().get_nodes_in_group("persistent")
	for node: Node in persistent_nodes:
		var save_data: Dictionary = node.get_save_data()
		var save_key: String = save_data.keys()[0]
		_save_data[save_key] = save_data[save_key]
	
	_save_data_to_file()


#region Save/Load data to/from file

const COMPRESION_MODE: int = FileAccess.COMPRESSION_DEFLATE


func _load_data_from_file() -> void:
	var data_as_text: String = Globals.load_text_from_file(_file_path)
	# Check if there is any data
	if data_as_text == "":
		return
	
	# Decode save data when not in editor
	data_as_text = _decode_data(data_as_text)
	
	_save_data = JSON.parse_string(data_as_text)

func _save_data_to_file() -> void:
	var data_as_text: String = JSON.stringify(_save_data, "\t")
	
	# Encode save data when not in the editor
	data_as_text = _encode_data(data_as_text)
	
	Globals.save_text_to_file(_file_path, data_as_text)


func _encode_data(data: String) -> String:
	if Globals.in_editor:
		return data
	
	var ascii_encode: PackedByteArray = data.to_ascii_buffer()
	var compress: PackedByteArray = ascii_encode.compress(COMPRESION_MODE)
	var hex_encode: String = compress.hex_encode()
	return hex_encode

func _decode_data(data: String) -> String:
	if Globals.in_editor:
		return data
	
	var hex_decode: PackedByteArray = data.hex_decode()
	var decompress: PackedByteArray = hex_decode.decompress_dynamic(-1, COMPRESION_MODE)
	var ascii_decode: String = decompress.get_string_from_ascii()
	return ascii_decode

#endregion
