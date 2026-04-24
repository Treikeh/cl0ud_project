extends Node3D


@export var _head_maker: Node3D

@export_group("Dialogue")
@export var _start_dialogue: DialogueData
@export var _spoken_dialogue: DialogueData
@export var _secret_dialogue: DialogueData

var _times_spoken: int = 0


func _on_interacted(player: Player) -> void:
	match _times_spoken:
		# First time we speak to nils
		_: player.hud.start_dialogue(_start_dialogue)
		# Every other time we speak to nils
		#_: player.hud.start_dialogue(_spoken_dialogue)
	
	_times_spoken += 1
	player.update_look_position(_head_maker.global_position)


func _ready() -> void:
	# Connect spoken dialogue choices to a function
	_spoken_dialogue.choice_made.connect(_on_spoken_dialogue_choice_made)


func _on_spoken_dialogue_choice_made(choice: int) -> void:
	# Get the player
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		0: # Yes
			player.hud.start_dialogue.call_deferred(_secret_dialogue)
		1: # No
			pass
