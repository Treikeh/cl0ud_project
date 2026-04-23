@tool
extends FishData
class_name MailData


@export var from: String = "From"
@export var to: String = "To"
@export var subject: String = "Subject"
@export_multiline() var content: String = "Content"


func get_display_scene() -> String:
	return "uid://cyuo21l0gwdm5"

func get_type() -> String:
	return Fish.Type.keys()[Fish.Type.MAIL]
