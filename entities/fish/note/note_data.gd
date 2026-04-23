@tool
extends FishData
class_name NoteData


@export_multiline() var text: String = "Text"


func get_display_scene() -> String:
	return "uid://ds5flwipduxn0"


func get_type() -> String:
	return Fish.Type.keys()[Fish.Type.NOTE]
