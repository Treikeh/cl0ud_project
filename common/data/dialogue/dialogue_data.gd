extends Resource
class_name DialogueData

@warning_ignore("unused_signal")
signal choice_made(choice: int)

@export var name: String = "Name"
@export var lines: Array[String] = []
@export var choices: Array[String] = []
