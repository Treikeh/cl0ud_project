extends Resource
class_name ItemData


@export var name: String = "Name"
@export_multiline() var description: String = "Description"
@export var value: int = 0
@export var icon: Texture
@export_file("*.tscn") var mesh_scene: String
