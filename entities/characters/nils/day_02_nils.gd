extends Node3D


@export var _head_maker: Node3D

@export_group("Dialogue")
@export var _repeat_dialogues: Array[DialogueData]
@export var _tips_dialogues: Array[DialogueData]
@export var _no_more_tips_dialogue: DialogueData


func _ready() -> void:
	for dialogue: DialogueData in _repeat_dialogues:
		dialogue.choice_made.connect(_on_repeat_dialogue_choice_made)


func _on_interacted(player: Player) -> void:
	if _tips_dialogues.is_empty():
		player.hud.start_dialogue(_no_more_tips_dialogue)
	else:
		player.hud.start_dialogue(_repeat_dialogues.pick_random())
	
	player.update_look_position(_head_maker.global_position)


func _on_repeat_dialogue_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		_:
			var tips_dialogue: DialogueData = _tips_dialogues[0]
			player.hud.start_dialogue.call_deferred(tips_dialogue)
			_tips_dialogues.pop_at(0)
