extends Node


const FILE_NAME: String = "settings.ini"

var _settings: Dictionary = {}

@onready var _file_path: String = Globals.get_data_dir() + FILE_NAME


func _ready() -> void:
	_load_settings_from_file()

func _exit_tree() -> void:
	_save_settings_to_file()


#region Save/Load settings to/from file

func _load_settings_from_file() -> void:
	var settings_as_text: String = Globals.load_text_from_file(_file_path)
	# Check if there are any settings
	if settings_as_text == "":
		return
	
	_settings = JSON.parse_string(settings_as_text)

func _save_settings_to_file() -> void:
	var settings_as_text: String = JSON.stringify(_settings, "\t")
	Globals.save_text_to_file(_file_path, settings_as_text)

#endregion
