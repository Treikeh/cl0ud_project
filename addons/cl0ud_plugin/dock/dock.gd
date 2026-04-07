@tool
extends Control

const ITEM_SAVE_PATH: String = "res://debug/items/"
const FISH_DATA_SAVE_PATH: String = "res://debug/fish_data/"
const DIALOGUE_SAVE_PATH: String = "res://debug/dialogue/"

var _file_paths: Dictionary = {}
var _debug_settings: Dictionary = {}

@export var _enable_save_check_box: CheckBox
@export var _item_button: Button
@export var _fish_data_button: Button
@export var _dialogue_button: Button


func _ready() -> void:
	_enable_save_check_box.toggled.connect(_enable_save)
	_item_button.pressed.connect(_parse_file.bind("items"))
	_fish_data_button.pressed.connect(_parse_file.bind("fish_data"))
	_dialogue_button.pressed.connect(_parse_file.bind("dialogue"))
	
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


#region Parse data

func _parse_file(file: String) -> void:
	# Load file paths
	_file_paths = Globals.load_data_from_file(Globals.SETTINGS_FILE)
	var file_paths: Dictionary = _file_paths.get("%s_file_paths" % file)
	
	# Get data from file
	var rows: Array[PackedStringArray] = _get_file_data(file)
	if rows.is_empty():
		return
	
	# Create differnt resources based on file
	match file:
		"items":
			_create_item_resources(rows, file_paths)
		"fish_data":
			_create_fish_data(rows, file_paths)
		"dialogue":
			_create_dialogue_resources(rows, file_paths)
	
	# Update and save the uids of the new files
	_file_paths.set("%s_file_paths" % file, file_paths)
	Globals.save_data_to_file(Globals.SETTINGS_FILE, _file_paths)
	# Refresh files
	EditorInterface.get_resource_filesystem().scan()


# Get all the data from a tsv file
func _get_file_data(file: String) -> Array[PackedStringArray]:
	# Check if the file exists
	print("Parsing %s.tsv file" % file)
	var file_path: String = "res://debug/%s.tsv" % file
	if not FileAccess.file_exists(file_path):
		push_error("%s file not found" % file_path)
		return []
	
	# Get the text from the file
	var file_access := FileAccess.open(file_path, FileAccess.READ)
	var file_text: String = file_access.get_as_text()
	# Turn the text into an array where each line is an array element
	var lines: PackedStringArray = file_text.split("\r")
	# Remove columns description line
	lines.remove_at(0)
	
	# Turn each line into an array with where each element is seperated by a tab
	var rows: Array[PackedStringArray]
	for line: String in lines:
		var row: PackedStringArray = line.split("\t")
		# Remove the new line element form the id
		row[0] = row[0].trim_prefix("\n")
		rows.append(row)
	
	return rows


func _file_exists(file_paths: Dictionary, id: String) -> bool:
	return file_paths.has(id) and ResourceUID.has_id(ResourceUID.text_to_id(file_paths[id]))


func _save_resource(resource: Resource, path: String, file_paths: Dictionary, id: String) -> void:
	var save_result: Error = ResourceSaver.save(resource, path)
	# Save resource uid so that we can check if it exits for the next time we want to ->
	# <- parse the dialogue data.
	var resource_id: int = ResourceLoader.get_resource_uid(path)
	file_paths[id] = ResourceUID.id_to_text(resource_id)
	print('Saving "%s", Result: %s' % [path, save_result])


func _create_item_resources(data: Array[PackedStringArray], file_paths: Dictionary) -> void:
	# Create item data for each data element
	for row: PackedStringArray in data:
		var id: String = row[0]
		var path: String = ITEM_SAVE_PATH + id + ".tres"
		
		var item := ItemData.new()
		if _file_exists(file_paths, id):
			path = ResourceUID.uid_to_path(file_paths[id])
			item = load(path)
		
		# Get item data
		var item_name: String = row[1]
		#var description: String = row[2]
		var value: int = str_to_var(row[3])
		var type: String = row[4]
		print(type)
		var icon: Texture
		var mesh_scene: String
		var fish_data: FishData
		
		match type:
			"MAIL", "NOTE", "MESSAGE":
				var fish_type: String = type.to_lower()
				# Get stuff from fish data
				icon = load("res://entities/fish/%s/%s_icon.png" % [fish_type, fish_type])
				mesh_scene = "res://entities/fish/%s/%s_mesh.tscn" % [fish_type, fish_type]
				fish_data = load("res://entities/fish/%s/data/%s" % [fish_type, row[7]])
			_:
				icon = load(row[5])
				mesh_scene = row[6]
		
		# Set item data
		item.name = item_name
		item.value = value
		item.type = type
		item.icon = icon
		item.mesh_scene = mesh_scene
		item.fish_data = fish_data
		
		_save_resource(item, path, file_paths, id)


func _create_fish_data(data: Array[PackedStringArray], file_paths: Dictionary) -> void:
	# Create item data for each data element
	for row: PackedStringArray in data:
		var id: String = row[0]
		var path: String = FISH_DATA_SAVE_PATH + id + ".tres"
		
		var fish: FishData
		if _file_exists(file_paths, id):
			path = ResourceUID.uid_to_path(file_paths[id])
			fish = load(path)
		
		# Create the right fish data type
		var type: String = row[1]
		match type:
			"MAIL":
				# Get mail data
				var text: String = row[2]
				# Get where the differnt parts starts
				var from: int = text.find("[f]")
				var to: int = text.find("[t]")
				var subject: int = text.find("[s]")
				var content: int = text.find("[c]")
				
				# Set mail data
				if fish == null:
					fish = MailData.new()
				# Get parts of the string that match with the different parts
				fish.from = text.substr(from, to - from).trim_prefix("[f]")
				fish.to = text.substr(to, subject - to).trim_prefix("[t]")
				fish.subject = text.substr(subject, content - subject).trim_prefix("[s]")
				fish.content = text.substr(content, text.length() - content).trim_prefix("[c]")
				#print("From: %s, To: %s, Subject: %s, Content: %s" % [fish.from, fish.to, fish.subject, fish.content])
			"NOTE":
				# Get note data
				var text: String = row[2]
				
				# Set note data
				if fish == null:
					fish = NoteData.new()
				fish.text = text
			"MESSAGE":
				# Get message data
				var text: String = row[2]
				var sender: int = text.find("[s]")
				var recipient: int = text.find("[r]")
				
				# Set message data
				if fish == null:
					fish = MessageData.new()
				fish.sender = text.substr(sender, recipient - sender).trim_prefix("[s]")
				fish.recipient = text.substr(recipient, text.length() - recipient).trim_prefix("[r]")
		
		_save_resource(fish, path, file_paths, id)	


func _create_dialogue_resources(data: Array[PackedStringArray], file_paths: Dictionary) -> void:
	# Create dialogue resources for each data element
	for row: PackedStringArray in data:
		# Get the id from the row
		var id: String = row[0]
		# Get the default file save path
		var path: String = DIALOGUE_SAVE_PATH + id + ".tres"
		
		# Create new dialogue dialogue object
		var dialogue := DialogueData.new()
		# Check if a reference to the files exists
		if _file_exists(file_paths, id):
			# Set the save path to the path of the file
			path = ResourceUID.uid_to_path(file_paths[id])
			# Load the old file
			dialogue = load(path)
		
		# Get choices
		var choices: Array[String] = []
		# Remove the space in front of each option
		for choice: String in row[3].split("|"):
			choice = choice.strip_edges()
			choices.append(choice)
		
		# Set data on the dialogue object
		dialogue.name = row[1]
		dialogue.text = row[2]
		dialogue.choices = choices
		
		_save_resource(dialogue, path, file_paths, id)

#endregion
