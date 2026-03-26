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
	# Get a random fish type
	var type: Type = randi_range(0, Type.values().size() - 1) as Type
	
	# Create item data
	item_data = _create_item_data(type)
	
	# Spawn fish mesh
	var mesh: Node3D = load(item_data.mesh_scene).instantiate()
	add_child(mesh)


func _create_item_data(type: Type) -> ItemData:
	# Get fish type as text and its files path
	var type_as_text: String = Type.keys()[type].to_lower()
	var files_path: String = FOLDER_PATH + type_as_text + "/"
	
	# Create a new item data based on the file
	var data := ItemData.new()
	data.name = str(randi())
	data.value = randi_range(1, 10)
	data.icon = load(files_path + type_as_text + "_icon.png")
	data.mesh_scene = files_path + type_as_text + "_mesh.tscn"
	data.dispaly_scene = files_path + type_as_text + "_data_dispaly.tscn"
	data.fish_data = _get_fish_data(files_path)
	return data


# Get a random data file from the foler of the fish type
func _get_fish_data(path: String) -> FishData:
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
	print(data_folder_path + file)
	# Load the file
	return load(data_folder_path + file)
