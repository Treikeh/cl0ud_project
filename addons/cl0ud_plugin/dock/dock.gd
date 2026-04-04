@tool
extends Control


const DIALOGUE_SAVE_PATH: String = "res://debug/parse_dialogue/"

var _debug_settings: Dictionary = {}
var _dialogue_file_paths: Dictionary = {}

@export var _enable_save_check_box: CheckBox
@export var _item_button: Button
@export var _dialogue_button: Button


func _ready() -> void:
	_enable_save_check_box.toggled.connect(_enable_save)
	_item_button.pressed.connect(_parse_item_file)
	_dialogue_button.pressed.connect(_parse_dialogue_file)
	
	# Set up dock
	_debug_settings = Globals.load_data_from_file(Globals.DEBUG_SETTINGS_FILE)
	if not _debug_settings.is_empty():
		_enable_save_check_box.button_pressed = str_to_var(_debug_settings.save_enabled)


func _enable_save(toggled_on: bool) -> void:
	# Load settings
	_debug_settings = Globals.load_data_from_file(Globals.DEBUG_SETTINGS_FILE)
	
	# Update save enabled
	_debug_settings.save_enabled = var_to_str(toggled_on)
	
	# Save the new settings
	Globals.save_data_to_file(Globals.DEBUG_SETTINGS_FILE, _debug_settings)


func _parse_item_file() -> void:
	pass


func _parse_dialogue_file() -> void:
	# Load settings
	_debug_settings = Globals.load_data_from_file(Globals.DEBUG_SETTINGS_FILE)
	_dialogue_file_paths = _debug_settings.dialogue_file_paths
	
	
	print("Parsing dialogue.tsv file")
	var file: String = "res://debug/parse_dialogue/dialogue.tsv"
	if not FileAccess.file_exists(file):
		push_error("Dialogue file not found")
		return
	
	# Get text on file
	var file_access := FileAccess.open(file, FileAccess.READ)
	var file_text: String = file_access.get_as_text()
	var lines: PackedStringArray = file_text.split("\r")
	lines.remove_at(0)
	
	var rows: Array[PackedStringArray]
	for line: String in lines:
		var row: PackedStringArray = line.split("\t")
		# Remove the new line element form the id
		row[0] = row[0].trim_prefix("\n")
		rows.append(row)
	
	# Create dialogue resources for each row
	for row: PackedStringArray in rows:
		# Get the id from the row
		var id: String = row[0]
		# Create dialogue dialogue object
		var dialogue := DialogueData.new()
		
		# Get the default file save path
		var file_path: String = DIALOGUE_SAVE_PATH + id + ".tres"
		# Check if a reference to the files exists
		if _dialogue_file_paths.has(id) and ResourceUID.has_id(ResourceUID.text_to_id(_dialogue_file_paths[id])):
			# Set the save path to the path of the file
			file_path = ResourceUID.uid_to_path(_dialogue_file_paths[id])
			# Load the old file if it exists
			dialogue = load(file_path)
		
		# Get data from the row
		#var chr_name: String = row[1]
		var text: String = row[2]
		# Set dialogue data
		dialogue.text = text
		# Save dialogue data
		var save_result: Error = ResourceSaver.save(dialogue, file_path)
		# Save dialogue data uid so that we can check if it exits for the next time we want to
		# parse the dialogue data.
		var resource_id: int = ResourceLoader.get_resource_uid(file_path)
		_dialogue_file_paths[id] = ResourceUID.id_to_text(resource_id)
		print('Saving "%s", Result: %s' % [file_path, save_result])
	
	# Update and save the new dialogue file paths
	_debug_settings.dialogue_file_paths = _dialogue_file_paths
	Globals.save_data_to_file(Globals.DEBUG_SETTINGS_FILE, _debug_settings)
