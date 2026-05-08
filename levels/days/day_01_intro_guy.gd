extends Node3D


@export var _trigger_dialogue: DialogueData
@export var _old_man_dialogue: DialogueData
@export var _head_marker: Node3D

var _has_spoken: bool = false


func _ready() -> void:
	_trigger_dialogue.choice_made.connect(_on_trigger_dialogue_choice_made)


func _body_entered_trigger(body: Node3D) -> void:
	if body is Player and not _has_spoken:
		body.hud.start_dialogue(_trigger_dialogue)
		body.update_look_position(_head_marker.global_position)
		_has_spoken = true


func _on_trigger_dialogue_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		0: # Old man?
			player.hud.start_dialogue.call_deferred(_old_man_dialogue)
