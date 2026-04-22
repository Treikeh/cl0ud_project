extends Node3D


@export var _head_maker: Node3D

@export_group("Dialogue")
@export var _start_dialogue: Array[DialogueData]
@export var _allready_spoken_dialogue: Array[DialogueData]

var _has_spoken: bool = false


func _on_interacted(player: Player) -> void:
	if _has_spoken:
		player.hud.start_dialogue(_allready_spoken_dialogue)
	else:
		_has_spoken = true
		player.hud.start_dialogue(_start_dialogue)
	
	player.update_look_position(_head_maker.global_position)
