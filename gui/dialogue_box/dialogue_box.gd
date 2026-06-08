extends Control


signal dialogue_ended


const CHOICE_SCENE: PackedScene = preload("res://gui/dialogue_box/choice_entry/choice_entry.tscn")


@export var _name_label: Label
@export var _text_label: Label
@export var _dialogue_choice_container: Container
@export var _speech_sfx: FmodEventEmitter2D

var _show_chocies: bool = false
var _dialogue_progress: int = 0
var _dialogue: DialogueData


func with_data(dialogue: DialogueData) -> Control:
	_dialogue = dialogue
	return self


func _ready() -> void:
	_update_dialogue_box()


func _process(_delta: float) -> void:
	if _text_label.text == _dialogue.lines[_dialogue_progress] and not _speech_sfx.paused:
		_speech_sfx.paused = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("throw_hook"):
		if _dialogue_choice_container.get_child_count() > 0:
			pass
		else:
			_progress_dialogue()


func _update_dialogue_box() -> void:
	_speech_sfx.paused = false
	var line: String = _dialogue.lines[_dialogue_progress]
	_name_label.text = _dialogue.name
	_text_label.text = ""
	
	if _dialogue_progress >= _dialogue.lines.size() - 1 and not _dialogue.choices.is_empty():
		_show_chocies = true
	
	var tween: Tween = create_tween()
	tween.tween_property(_text_label, "text", line, line.length() / 50.0)
	tween.tween_interval(0.25)
	tween.tween_callback(_show_dialogue_choices)


func _end_dialogue() -> void:
	#NOTE: call_deferred to make the input of progressing the dialogue not immediately restart the
	# dialogue when it ends.
	dialogue_ended.emit.call_deferred()
	_dialogue.finished.emit()
	queue_free()


func _progress_dialogue() -> void:
	var desired_progress: int = _dialogue_progress + 1
	if desired_progress >= _dialogue.lines.size():
		if _show_chocies:
			_show_dialogue_choices()
			print("SHOW choices")
		else:
			_end_dialogue()
	else:
		_dialogue_progress = desired_progress
		_update_dialogue_box()


func _show_dialogue_choices() -> void:
	if not _show_chocies:
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for i: int in _dialogue.choices.size():
		var choice: String = _dialogue.choices[i]
		var button: Button = CHOICE_SCENE.instantiate().with_data(choice)
		button.pressed.connect(_on_dialogue_choice_selected.bind(button))
		_dialogue_choice_container.add_child(button)
	
	#NOTE: Call deferred to stop progress input to chose an option when the buttons spawn
	_dialogue_choice_container.get_child(0).grab_focus.call_deferred()
	_show_chocies = false


func _on_dialogue_choice_selected(choice: Control) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_end_dialogue()
	_dialogue.choice_made.emit(choice.get_index())
