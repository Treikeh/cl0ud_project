extends Resource
class_name DialogueData

@export var name: String = "Name"
@export_multiline() var text: String = "Dialogue"
@export var choices: Array[String] = []
