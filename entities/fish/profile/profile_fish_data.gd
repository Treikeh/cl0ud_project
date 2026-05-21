@tool
extends FishData
class_name ProfileFishData


@export var name: String = ""
@export var birthday: String = ""
@export var occupation: String = ""
@export var address: String = ""
@export var likes: String = ""
@export var dislikes: String = ""


func get_display_scene() -> String:
	return "uid://dqvaj563bfo8a"


func get_type() -> String:
	return Fish.Type.keys()[Fish.Type.PROFILE]
