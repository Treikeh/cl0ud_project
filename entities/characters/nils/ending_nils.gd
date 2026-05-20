extends Node3D


@export var _head_maker: Node3D

@export_group("Dialogue")
@export var _interact_dialogue: DialogueData
@export var _final_dialogue: DialogueData


func _ready() -> void:
	_interact_dialogue.choice_made.connect(_on_interact_dialogue_choice_made)
	_final_dialogue.choice_made.connect(_on_final_dialogue_choice_made)


func _on_interacted(player: Player) -> void:
	player.hud.start_dialogue(_interact_dialogue)
	player.update_look_position(_head_maker.global_position)


func _on_interact_dialogue_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		_:
			player.hud.start_dialogue.call_deferred(_final_dialogue)


func _on_final_dialogue_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	player.input.set_enabled.call_deferred(false)
	
	await get_tree().create_timer(0.5).timeout
	
	match choice:
		_:
			Globals.day_ended.emit()
