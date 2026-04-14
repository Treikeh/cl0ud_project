extends Control


signal dialogue_ended
signal dialouge_choice_made(choice: int)


@export var _name_label: Label
@export var _text_label: Label
@export var _dialogue_choice_container: Container

var _dialogue_progress: int = 0
var _dialogue: Array[DialogueData]


func with_data(dialogue: Array[DialogueData]) -> Control:
	_dialogue = dialogue
	return self


func _ready() -> void:
	_update_dialogue_box()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if _dialogue_choice_container.get_child_count() > 0:
			pass
		else:
			_progress_dialogue()


func _update_dialogue_box() -> void:
	var dialogue: DialogueData = _dialogue[_dialogue_progress]
	_name_label.text = dialogue.name
	_text_label.text = dialogue.text
	if not dialogue.choices.is_empty():
		_show_dialogue_choices(dialogue)


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


func _show_dialogue_choices(dialogue: DialogueData) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for choice: String in dialogue.choices:
		var button := Button.new()
		button.text = choice
		_dialogue_choice_container.add_child(button)
		button.pressed.connect(_on_dialogue_choice_selected.bind(button))
	
	#NOTE: Call deferred to stop progress input to chose an option when the buttons spawn
	_dialogue_choice_container.get_child(0).grab_focus.call_deferred()


func _on_dialogue_choice_selected(choice: Control) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_end_dialogue()
	dialouge_choice_made.emit(choice.get_index())
