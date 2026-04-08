extends Node3D
class_name Fish


enum Type {
	MAIL,
	MESSAGE,
	NOTE,
}

const FOLDER_PATH: String = "res://entities/fish/"

var item_data: ItemData
var _loot_pool: LootPool


func with_data(loot_pool: LootPool) -> Fish:
	_loot_pool = loot_pool
	return self


func _ready() -> void:
	item_data = _create_item_data()
	
	# Spawn fish mesh
	var mesh: Node3D = load(item_data.mesh_scene).instantiate()
	add_child(mesh)


func _create_item_data() -> ItemData:
	var type: Type = _get_random_type()
	# Get fish type as text and its files path
	var type_as_text: String = Type.keys()[type].to_lower()
	var files_path: String = FOLDER_PATH + type_as_text + "/"
	var fish_data: String = _get_fish_data_path(files_path)
	
	# Create dict with all the data the ItemData class needs
	var data: Dictionary = {
		"name": fish_data.split("/")[-1].trim_suffix(".tres"),
		"value": _loot_pool.get_value(),
		"type": type_as_text.to_upper(),
		"icon": files_path + type_as_text + "_icon.png",
		"mesh_scene": files_path + type_as_text + "_mesh.tscn",
		"fish_data": fish_data
	}
	return ItemData.new(data)


func _get_random_type() -> Type:
	# Dictionary[Type, float(weight chance to get the value)]
	var types: Dictionary[Type, float] = {
		Type.MAIL: Globals.mail_fish_chance,
		Type.NOTE: Globals.note_fish_chance,
		Type.MESSAGE: Globals.message_fish_chance,
	}
	#TODO: Get a random fish based on the chances
	var type: Type = randi_range(0, types.values().size() - 1) as Type
	return type


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
