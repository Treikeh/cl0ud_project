extends Control


signal dialogue_ended


@export var _name_label: Label
@export var _text_label: Label

var _dialogue_progress: int = 0
var _dialogue: Array[DialogueData]


func with_data(dialogue: Array[DialogueData]) -> Control:
	_dialogue = dialogue
	return self


func _ready() -> void:
	_update_dialogue_box()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_progress_dialogue()


func _update_dialogue_box() -> void:
	var dialogue: DialogueData = _dialogue[_dialogue_progress]
	_name_label.text = dialogue.name
	_text_label.text = dialogue.text


func _end_dialogue() -> void:
	#NOTE: call_deferred to make the input of progressing the dialogue not immediately restart the
	# dialogue when it ends.
	dialogue_ended.emit.call_deferred()
	queue_free()


func _progress_dialogue() -> void:
	var desired_progress: int = _dialogue_progress + 1
	if desired_progress >= _dialogue.size():
		_end_dialogue()
	else:
		_dialogue_progress = desired_progress
		_update_dialogue_box()
