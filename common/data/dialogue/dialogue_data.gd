extends Resource
class_name DialogueData

@warning_ignore_start("unused_signal")
signal choice_made(choice: int)
signal finished

@export var name: String = "Name"
@export var lines: Array[String] = []
@export var choices: Array[String] = []
