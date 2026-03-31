extends Node


const FILE_NAME: String = "settings.ini"

var _settings: Dictionary = {}

@onready var _file_path: String = Globals.get_data_dir() + FILE_NAME


func _ready() -> void:
	_load_settings_from_file()

func _exit_tree() -> void:
	_save_settings_to_file()


func _load_settings_from_file() -> void:
	_settings = Globals.load_data_from_file(_file_path)


func _save_settings_to_file() -> void:
	Globals.save_data_to_file(_file_path, _settings)
