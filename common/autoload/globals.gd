extends Node


const USER_PATH: String = "user://"
const DEBUG_PATH: String = "res://debug/"

@onready var in_editor: bool = OS.has_feature("editor")

func get_data_dir() -> String:
	return DEBUG_PATH if in_editor else USER_PATH


func load_text_from_file(file_path: String) -> String:
	var text: String = ""
	# Check if file exists
	if FileAccess.file_exists(file_path):
		# Open file so that text can be read from it
		var file_access := FileAccess.open(file_path, FileAccess.READ)
		# Get the text from the file
		text = file_access.get_as_text()
	return text


func save_text_to_file(file_path: String, text: String) -> void:
	# Create/open a file to write to
	var file_access := FileAccess.open(file_path, FileAccess.WRITE)
	# Save text to file
	file_access.store_string(text)
