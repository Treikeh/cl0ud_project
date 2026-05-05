@tool
extends Control

const ITEM_SAVE_PATH: String = "res://common/data/items/"
const FISH_DATA_SAVE_PATH: String = "res://common/data/fish/"
const DIALOGUE_SAVE_PATH: String = "res://common/data/dialogue/"
const RECIPES_SAVE_PATH: String = "res://common/data/recipes/"

var _file_paths: Dictionary = {}
var _debug_settings: Dictionary = {}

@export var _enable_save_check_box: CheckBox
@export var _recipes_button: Button
@export var _item_button: Button
@export var _fish_data_button: Button
@export var _dialogue_button: Button


func _ready() -> void:
	_enable_save_check_box.toggled.connect(_enable_save)
	_recipes_button.pressed.connect(_parse_file.bind("recipes"))
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
	# Get data from file
	var rows: Array[PackedStringArray] = _get_file_data(file)
	if rows.is_empty():
		return
	
	# Create differnt resources based on file
	match file:
		"items":
			_create_item_resources(rows)
		"fish_data":
			_create_fish_data(rows)
		"dialogue":
			_create_dialogue_resources(rows)
		"recipes":
			_create_recipes_data(rows)
	
	# Refresh files
	EditorInterface.get_resource_filesystem().scan()


# Get all the data from a tsv file
func _get_file_data(file: String) -> Array[PackedStringArray]:
	# Check if the file exists
	print("Parsing %s.tsv file" % file)
	var file_path: String = "res://common/data/%s.tsv" % file
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


func _save_resource(resource: Resource, path: String) -> void:
	var save_result: Error = ResourceSaver.save(resource, path)
	print('Saving "%s", Result: %s' % [path, save_result])


func _create_item_resources(data: Array[PackedStringArray]) -> void:
	var loot_table: Dictionary = {}
	# Create item data for each data element
	for row: PackedStringArray in data:
		var id: String = row[0]
		if id == "":
			continue
		var path: String = ITEM_SAVE_PATH + id + ".tres"
		
		var item := ItemData.new()
		
		# Get item data
		var item_name: String = row[1]
		var description: String = row[2]
		var value: int = int(row[3])
		var fish_data_path: String = row[4]
		
		var icon: Texture
		var mesh_scene: String
		var fish_data: FishData
		var item_type: String
		
		if fish_data_path != "":
			fish_data = load(FISH_DATA_SAVE_PATH + fish_data_path + ".tres")
			var fish_type: String = fish_data.get_type().to_lower()
			# Get stuff from fish data
			item_type = fish_type.to_upper()
			icon = load("res://entities/fish/%s/%s_icon.png" % [fish_type, fish_type])
			mesh_scene = "res://entities/fish/%s/%s_mesh.tscn" % [fish_type, fish_type]
			
			# Add the fish to the different loot tables
			var loot_tables: PackedStringArray = row[6].split(",")
			for table: String in loot_tables:
				table = table.to_upper().strip_edges()
				# Get the old loot table
				var old_table: Dictionary = {}
				old_table[table] = {}
				if loot_table.has(table):
					old_table[table] = loot_table[table]
				
				if not old_table[table].has(item_type):
					old_table[table][item_type] = {}
				
				# Create entry for loot table
				var entry: Dictionary = { path: row[5]}
				var type_table: Dictionary = {}
				if old_table[table].has(item_type):
					type_table = old_table[table][item_type]
				
				type_table.merge(entry)
				
				old_table[table][item_type].merge(type_table)
				loot_table.merge(old_table)
		else:
			item_type = row[7]
			print(row[8])
			icon = load(row[8])
			mesh_scene = row[9]
		
		# Set item data
		item.name = item_name
		item.description = description
		item.value = value
		item.icon = icon
		item.type = item_type
		item.mesh_scene = mesh_scene
		item.fish_data = fish_data
		
		_save_resource(item, path)
	Globals.save_data_to_file(Globals.FISH_LOOT_TABLE_FILE, loot_table)


func _create_fish_data(data: Array[PackedStringArray]) -> void:
	# Create item data for each data element
	for row: PackedStringArray in data:
		var id: String = row[0]
		if id == "":
			continue
		
		var type: String = row[1]
		var path: String = FISH_DATA_SAVE_PATH + id + ".tres"
		
		var fish: FishData
		
		# Create the right fish data type
		match type:
			"MAIL":
				# Get mail data
				var text: String = row[2]
				# Get where the differnt parts starts
				var from: int = text.find("{from}")
				var to: int = text.find("{to}")
				var subject: int = text.find("{subject}")
				var content: int = text.find("{content}")
			
				var from_text: String = text.substr(from, to - from).trim_prefix("{from}")
				var to_text: String = text.substr(to, subject - to).trim_prefix("{to}")
				var subject_text: String = text.substr(subject, content - subject).trim_prefix("{subject}")
				var content_text: String = text.substr(content, text.length() - content).trim_prefix("{content}")
				# Turn fake new line markers into real new line markers
				content_text = content_text.replace("/n", "\n")
				
				fish = MailData.new()
				# Get parts of the string that match with the different parts
				fish.from = from_text
				fish.to = to_text
				fish.subject = subject_text
				fish.content = content_text
			"NOTE":
				# Get note data
				var text: String = row[2]
				text = text.replace("/n", "\n")
				
				fish = NoteData.new()
				fish.text = text
			"MESSAGE":
				# Get message data
				var text: String = row[2]
				var s_start: int = text.find("{sender}")
				var r_start: int = text.find("{receiver}")
				var r_end: int = text.find("|", r_start)
				
				var sender: String = text.substr(s_start, r_start - s_start).trim_prefix("{sender}")
				#sender = sender.strip_edges()
				var recipient: String = text.substr(r_start, r_end - r_start).trim_prefix("{receiver}")
				#recipient = recipient.strip_edges()
				
				var content_text: String = text.substr(r_end + 1, text.length() - r_end)
				content_text = content_text.replace("/n", "\n")
				var content: Array = content_text.split("{")
				content.pop_front()
				
				# Set up the messages array
				var messages: Array[Dictionary] = []
				for message: String in content:
					var lines: Array = message.split("|")
					lines[0] = lines[0].trim_prefix("from}").trim_prefix("to}").trim_prefix("system}")
					var who: String = recipient if message.begins_with("from}") else sender
					var dict: Dictionary = {
						"WHO": who if not message.begins_with("system}") else "SYSTEM",
						"LINES": lines
					}
					messages.append(dict)
				
				fish = MessageData.new()
				fish.sender = sender
				fish.recipient = recipient
				fish.messages = messages
			"JUNK":
				fish = JunkData.new()
		
		_save_resource(fish, path)


func _create_dialogue_resources(data: Array[PackedStringArray]) -> void:
	# Create dialogue resources for each data element
	for row: PackedStringArray in data:
		# Get the id from the row
		var id: String = row[0]
		if id == "":
			continue
		# Get the default file save path
		var path: String = DIALOGUE_SAVE_PATH + id + ".tres"
		
		# Create new dialogue dialogue object
		var dialogue := DialogueData.new()
		
		var lines: Array[String] = []
		for line: String in row[2].split("|"):
			line = line.strip_edges()
			if line != "":
				lines.append(line)
		
		# Get choices
		var choices: Array[String] = []
		# Remove the space in front of each option
		for choice: String in row[3].split("|"):
			choice = choice.strip_edges()
			if choice != "":
				choices.append(choice)
		
		# Set data on the dialogue object
		dialogue.name = row[1]
		dialogue.lines = lines
		dialogue.choices = choices
		
		_save_resource(dialogue, path)


func _create_recipes_data(data: Array[PackedStringArray]) -> void:
	for row: PackedStringArray in data:
		# Get the id from the row
		var id: String = row[0]
		if id == "":
			continue
		# Get the default file save path
		var path: String = RECIPES_SAVE_PATH + id + ".tres"
		
		var recipe := ProfileRecipe.new()
		
		var input: ItemData = load(ITEM_SAVE_PATH + row[1] + ".tres")
		var outputs: Array[ItemData] = []
		
		var output_entries: PackedStringArray = row[2].split(",")
		for entry: String in output_entries:
			outputs.append(load(ITEM_SAVE_PATH + entry.strip_edges() + ".tres"))
		
		recipe.input = input
		recipe.outputs = outputs
		
		_save_resource(recipe, path)

#endregion
