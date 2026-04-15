extends FishData
class_name MessageData


@export var sender: String = "Sender"
@export var recipient: String = "Recipient"
@export var messages: Array[Dictionary] = []


func get_display_scene() -> String:
	return "uid://d30nisxmluxd1"
