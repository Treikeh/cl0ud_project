@tool
extends Control


const DIALOGUE_SAVE_PATH: String = "res://debug/parse_dialogue/"

var _debug_settings: Dictionary = {}

@export var _enable_save_check_box: CheckBox
@export var _dialogue_button: Button


func _ready() -> void:
	_enable_save_check_box.toggled.connect(_enable_save)
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


func _parse_dialogue_file() -> void:
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
		# Get data from the row
		var id: String = row[0]
		#var chr_name: String = row[1]
		var text: String = row[2]
		
		# Create new dialogue data resource
		var dialogue := DialogueData.new()
		dialogue.text = text
		# Save dialogue data
		var save_file: String = DIALOGUE_SAVE_PATH + id + ".tres"
		var save_result: Error = ResourceSaver.save(dialogue, save_file)
		print('Saving "%s", Result: %s' % [save_file, save_result])
