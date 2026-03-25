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
	
	print(files_path)
	
	var data := ItemData.new()
	data.name = str(randi())
	data.value = randi_range(1, 10)
	data.icon = load(files_path + type_as_text + "_icon.png")
	data.mesh_scene = files_path + type_as_text + "_mesh.tscn"
	data.fish_data = _create_fish_data(type)
	return data


func _create_fish_data(type: Type) -> FishData:
	match type:
		Type.MAIL:
			return MailData.new()
		Type.MESSAGE:
			return MessageData.new()
		Type.NOTE:
			return NoteData.new()
		_:
			return MailData.new()
