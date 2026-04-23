@tool
extends FishData
class_name JunkData


func get_random_text() -> String:
	return str(randi())


func get_display_scene() -> String:
	return "uid://cm5syldr2f2q6"

func get_type() -> String:
	return Fish.Type.keys()[Fish.Type.JUNK]
