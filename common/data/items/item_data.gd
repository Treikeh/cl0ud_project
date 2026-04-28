extends Resource
class_name ItemData


@export var name: String = "Name"
@export var value: int = 0
@export var type: String = ""
@export var icon: Texture
@export_file("*.tscn") var mesh_scene: String
@export var fish_data: FishData


func _init(data: Dictionary = {}) -> void:
	if data.is_empty():
		return
	
	name = data.name
	value = int(data.value)
	type = data.type
	icon = load(data.icon) if data.icon != "" else null
	mesh_scene = data.mesh_scene
	fish_data = load(data.fish_data) if data.fish_data != "" else null


func get_data() -> Dictionary:
	var data: Dictionary = {
		"name": name,
		"value": value,
		"type": type,
		"icon": icon.resource_path if icon != null else "",
		"mesh_scene": mesh_scene,
		"fish_data": fish_data.resource_path if fish_data != null else "",
	}
	return data
