extends Control


@export var _interact_prompt: Label


func update_interact_prompt(prompt: String) -> void:
	_interact_prompt.text = prompt
