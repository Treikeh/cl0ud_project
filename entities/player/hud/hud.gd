extends Control
class_name Hud


const DIALOGUE_BOX_SCENE: PackedScene = preload("uid://4tbnv1ykb0mi")


@export var _interact_prompt: Label
@export var _fish_collected_promtp: Control

@onready var _player: Player = get_owner()


func _ready() -> void:
	_player.hud = self
	
	Globals.fish_collected.connect(_on_fish_collected)
	
	_fish_collected_promtp.hide()


func update_interact_prompt(prompt: String) -> void:
	_interact_prompt.visible = _player.input.is_enabled()
	_interact_prompt.text = prompt


func start_dialogue(dialogue: DialogueData) -> Control:
	_player.input.set_enabled(false)
	
	var dialogue_box: Control = DIALOGUE_BOX_SCENE.instantiate().with_data(dialogue)
	add_child(dialogue_box)
	dialogue_box.dialogue_ended.connect(_on_dialogue_ended)
	return dialogue_box


func _on_dialogue_ended() -> void:
	_player.input.set_enabled(true)
	_player.update_look_position(Vector3.ZERO)


func _on_fish_collected(item: ItemData) -> void:
	_fish_collected_promtp.open(item)
