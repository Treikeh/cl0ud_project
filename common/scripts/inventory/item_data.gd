extends Resource
class_name ItemData


@export var name: String = "Name"
@export var value: int = 0
@export var icon: Texture
@export_file("*.tscn") var mesh_scene: String
@export_file("*.tscn") var dispaly_scene: String
@export var fish_data: FishData
