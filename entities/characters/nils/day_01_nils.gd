extends Node3D


@export var _head_maker: Node3D

@export_group("Dialogue")
@export var _start_dialogue: DialogueData
@export var _spoken_dialogue: DialogueData

var _times_spoken: int = 0


func _on_interacted(player: Player) -> void:
	match _times_spoken:
		# First time we speak to nils
		0: player.hud.start_dialogue(_start_dialogue)
		# Every other time we speak to nils
		_: player.hud.start_dialogue(_spoken_dialogue)
	
	_times_spoken += 1
	player.update_look_position(_head_maker.global_position)
