extends Node3D
class_name Fish


enum Type {
	MAIL,
	MESSAGE,
	NOTE,
}

const FOLDER_PATH: String = "res://entities/fish/"

var item_data: ItemData


func _ready() -> void:
	var type: String = _get_random_type()
	if randi() & 1:
		item_data = _create_item_data(type)
		print("Create item data")
	else:
		print("Load item data")
		item_data = _get_random_item_from_loot_table(type)
	
	# Spawn fish mesh
	var mesh: Node3D = load(item_data.mesh_scene).instantiate()
	add_child(mesh)


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


func _get_random_item_from_loot_table(type: String) -> ItemData:
	# Loot table to the type of fish
	var type_loot_table: Dictionary = Globals.fish_loot_table[type]
	type_loot_table.sort()
	
	var item_path: String = type_loot_table.keys()[0]
	# Get the path of an item in the list which is close to the hook distance
	for item: String in type_loot_table:
		var rarity: int = int(type_loot_table[item])
		if rarity > Globals.hook_distance:
			item_path = item
			break
	return load(item_path)


func _get_random_type() -> String:
	# Dictionary[Type, float(weight chance to get the value)]
	var types: Dictionary[Type, float] = {
		Type.MAIL: Globals.mail_fish_chance,
		Type.NOTE: Globals.note_fish_chance,
		Type.MESSAGE: Globals.message_fish_chance,
	}
	#TODO: Get a random fish based on the chances
	var type: Type = randi_range(0, types.values().size() - 1) as Type
	var type_as_text: String = Type.keys()[type]
	return type_as_text


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
