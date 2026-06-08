extends Node3D
class_name Fish


enum Type {
	MAIL,
	MESSAGE,
	NOTE,
	JUNK,
	PROFILE,
}

const FOLDER_PATH: String = "res://entities/fish/"

var item_data: ItemData
var _loot_table: String


func with_data(loot_table: String) -> Fish:
	_loot_table = loot_table
	return self


func _ready() -> void:
	var type: String = _get_random_type()
	item_data = _get_random_item_from_loot_table(type)
	#if randi() & 1:
	#	item_data = _create_item_data(type)
	#	print("Create item data")
	#else:
	#	print("Load item data")
	##item_data = _get_random_item_from_loot_table(type)
	
	
	# Spawn fish mesh
	var mesh: Node3D = load(item_data.mesh_scene).instantiate()
	add_child(mesh)


func _get_random_type() -> String:
	# Dictionary[Type, float(weight chance to get the value)]
	var types: Dictionary[Type, float] = {
		Type.MAIL: Globals.mail_fish_chance,
		Type.NOTE: Globals.note_fish_chance,
		Type.MESSAGE: Globals.message_fish_chance,
		Type.JUNK: Globals.junk_fish_chance,
	}
	
	# Get all the fish types as an array
	var types_chances: Array[Type] = types.keys()
	# Randomize the order of the types
	types_chances.shuffle()
	# Sort types by the chances to get it (from low to high)
	types_chances.sort_custom(
		func(a: Type, b: Type) -> bool:
			return types[a] < types[b]
	)
	
	var total_chance: float = 0.0
	for chance: float in types:
		total_chance += chance
	
	var type: Type = randi_range(0, types.values().size() - 1) as Type
	var roll: float = randf_range(0.0, total_chance)
	for t: Type in types_chances:
		if roll < types[t]:
			type = t
			break
	
	#TODO: Get a random fish based on the chances
	var type_as_text: String = Type.keys()[type]
	return type_as_text


func _get_random_item_from_loot_table(type: String) -> ItemData:
	# Loot table to the type of fish
	while not Globals.fish_loot_table[_loot_table].has(type):
		print("No %s in %s loot table" % [type, _loot_table])
		type = _get_random_type()
	
	var type_loot_table: Dictionary = Globals.fish_loot_table[_loot_table][type]
	type_loot_table.sort()
	#print(JSON.stringify(type_loot_table, "\t"))
	
	# Get the total rarity of all the fish in the loot table
	#var total_rarity: int = 0
	#for fish: String in type_loot_table:
	#	total_rarity += int(type_loot_table[fish])
	
	var item_path: String = type_loot_table.keys()[0]
	var max_roll: int = int(Globals.hook_distance)
	#var max_value: int = int(type_loot_table.values()[-1])
	#if max_roll > max_value:
	#	max_roll = max_value - 1
	var roll: int = randi_range(0, max_roll)
	var t: int = 0
	for item: String in type_loot_table:
		var rarity: int = int(type_loot_table[item])
		if t >= roll:
			item_path = item
			print("Fish rarity: %s, Roll: %s, Hook distance: %s" % [rarity, roll, Globals.hook_distance])
			break
		t += rarity
	return load(item_path)


#region Generate fish

func _create_item_data(type: String) -> ItemData:
	# Get fish type as text and its files path
	var files_path: String = FOLDER_PATH + type.to_lower() + "/"
	var fish_data: String = _get_fish_data_path(files_path)
	
	# Create dict with all the data the ItemData class needs
	var data: Dictionary = {
		"name": str(randi_range(0, 10000)),
		"value": randi_range(5, 25),
		"type": type,
		"icon": files_path + type.to_lower() + "_icon.png",
		"mesh_scene": files_path + type.to_lower() + "_mesh.tscn",
		"fish_data": fish_data
	}
	return ItemData.new(data)


# Get a random data file from the flder of the fish type
func _get_fish_data_path(path: String) -> String:
	# Get the data folder for the fish type
	var data_folder_path: String = path + "data/"
	# Open the folder
	var dir := DirAccess.open(data_folder_path)
	# Get the names of all the files in the folder
	var files: PackedStringArray = dir.get_files()
	# Get the index of a random file in the folder
	var file_index: int = randi_range(0, files.size() - 1)
	# Get the name of the file at the file_index position
	var file: String = files[file_index]
	# Trim the file name
	#NOTE: Resource files are given the .remap suffix in exported builds
	file = file.trim_suffix(".remap")
	# Load the file
	return data_folder_path + file
