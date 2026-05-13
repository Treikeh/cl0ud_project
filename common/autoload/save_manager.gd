extends Node


const FILE_NAME: String = ".save"
const DEBUG_FILE_NAME: String = "save.ini"

var _save_data: Dictionary = {}

@onready var _file_name: String = DEBUG_FILE_NAME if Globals.in_editor else FILE_NAME
@onready var _save_path: String = Globals.get_data_dir() + _file_name


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
	_save_data["glboals"] = {"current_level": LevelManager.current_level_path}


func _load_data_from_file() -> void:
	if not Globals.save_enabled:
		return
	
	_save_data = Globals.load_data_from_file(_save_path)


func _save_data_to_file() -> void:
	if not Globals.save_enabled:
		return
	
	# Hide the save file if not in the editor
	var hidden: bool = false if Globals.in_editor else true
	Globals.save_data_to_file(_save_path, _save_data, hidden)
