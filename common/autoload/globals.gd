@tool
extends Node

@warning_ignore_start("unused_signal")
signal fish_hooked
signal fish_caught
signal fish_escaped
signal fish_collected(item: ItemData)

signal started_fishing
signal stopped_fishing

signal day_started
signal day_ended


const FISH_LOOT_TABLE_FILE: String = "res://common/data/items/_fish_loot_table.ini"

var hook_distance: float = 0.0
var time_of_day: float = 5.0

var mail_fish_chance: float = 1.0
var note_fish_chance: float = 1.0
var message_fish_chance: float = 1.0
var junk_fish_chance: float = 0.5

var fish_loot_table: Dictionary

var upgrades: Array[Upgrade]
var inv_items: Array[ItemData]
var pice_inv_items: Array[ItemData]


func _ready() -> void:
	_load_debug_settings()
	
	# Only load loot table when the game loads, not when the editor loads
	if not Engine.is_editor_hint():
		_load_fish_loot_table()
		$DebugMenu.show()


func _load_fish_loot_table() -> void:
	fish_loot_table = load_data_from_file(FISH_LOOT_TABLE_FILE)


#region Save/Load data to/from files

const USER_PATH: String = "user://"
const DEBUG_PATH: String = "res://debug/"

@onready var in_editor: bool = OS.has_feature("editor")


func get_data_dir() -> String:
	return DEBUG_PATH if in_editor else USER_PATH


func load_data_from_file(file_path: String) -> Dictionary:
	var data: Dictionary = {}
	# Check if file exists
	if FileAccess.file_exists(file_path):
		# Open file so that text can be read from it
		var file_access := FileAccess.open(file_path, FileAccess.READ)
		# Get the text from the file
		data = JSON.parse_string(file_access.get_as_text())
	return data


func save_data_to_file(file_path: String, data: Dictionary, hidden: bool = false) -> void:
	# Create/open a file to write to
	var file_access := FileAccess.open(file_path, FileAccess.WRITE)
	# Save the data to the file
	file_access.store_string(JSON.stringify(data, "\t"))
	# Hide the file
	FileAccess.set_hidden_attribute(file_path, hidden)

#endregion


#region Debug

const DEBUG_SETTINGS_FILE: String = "res://debug/debug_settings.ini"

var save_enabled: bool = true

func _load_debug_settings() -> void:
	# Don't load debug settings when not in the editor
	if not in_editor:
		return
	
	# Load and set debug settings
	var settings: Dictionary = Globals.load_data_from_file(DEBUG_SETTINGS_FILE)
	if not settings.is_empty():
		save_enabled = str_to_var(settings.save_enabled)
	

#endregion
