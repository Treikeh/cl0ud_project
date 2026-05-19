extends Node3D


@export var _head_maker: Node3D

@export_group("Dialogue")
@export var _start_dialogue: DialogueData
@export var _chops_dialogue: DialogueData
@export var _spoken_dialogue: DialogueData
@export var _teach_fishing_dialogue: DialogueData
@export var _repeat_dialogue: DialogueData
@export var _fishing_rod_upgrade: Upgrade

var _times_spoken: int = 0
var _caught_fish: bool = false


func _ready() -> void:
	Globals.fish_caught.connect(func(): _caught_fish = true)
	
	_start_dialogue.choice_made.connect(_on_start_dialogue_choice_made)


func _on_start_dialogue_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		_:
			player.hud.start_dialogue.call_deferred(_chops_dialogue)


func _on_interacted(player: Player) -> void:
	if Globals.upgrades.has(_fishing_rod_upgrade):
		if _caught_fish:
			player.hud.start_dialogue(_repeat_dialogue)
		else:
			player.hud.start_dialogue(_teach_fishing_dialogue)
		return
	
	match _times_spoken:
		# First time we speak to nils
		0: 
			player.hud.start_dialogue(_start_dialogue)
			_times_spoken += 1
		# Every other time we speak to nils
		_: player.hud.start_dialogue(_spoken_dialogue)
	
	player.update_look_position(_head_maker.global_position)
