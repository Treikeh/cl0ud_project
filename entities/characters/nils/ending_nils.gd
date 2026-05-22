extends Node3D


@export var _head_maker: Node3D

@export_group("Dialogue")
@export var _interact_dialogue: DialogueData
@export var _peaceful_dialogue: DialogueData
@export var _deadzone_dialogue: DialogueData
@export var _dialogue_02: DialogueData
@export var _dialogue_03: DialogueData
@export var _dialogue_04: DialogueData
@export var _dialogue_05: DialogueData
@export var _dialogue_06: DialogueData
@export var _final_dialogue: DialogueData


var _player: Player


func _ready() -> void:
	_interact_dialogue.choice_made.connect(_on_interact_dialogue_choice_made)
	
	_peaceful_dialogue.finished.connect(_on_choice_01_made)
	_deadzone_dialogue.finished.connect(_on_choice_01_made)
	
	_dialogue_02.choice_made.connect(_on_dialogue_02_choice_made)
	_dialogue_03.choice_made.connect(_on_dialogue_03_choice_made)
	_dialogue_04.choice_made.connect(_on_dialogue_04_choice_made)
	_dialogue_05.choice_made.connect(_on_dialogue_05_choice_made)
	_dialogue_06.choice_made.connect(_on_dialogue_06_choice_made)
	
	_final_dialogue.choice_made.connect(_on_final_dialogue_choice_made)


func _on_interacted(player: Player) -> void:
	_player = player
	_player.hud.start_dialogue(_interact_dialogue)
	_player.update_look_position(_head_maker.global_position)


func _on_interact_dialogue_choice_made(choice: int) -> void:
	match choice:
		0: _player.hud.start_dialogue.call_deferred(_peaceful_dialogue)
		1: _player.hud.start_dialogue.call_deferred(_deadzone_dialogue)


func _on_choice_01_made() -> void:
	_player.hud.start_dialogue.call_deferred(_dialogue_02)


func _on_dialogue_02_choice_made(_choice: int) -> void: _player.hud.start_dialogue.call_deferred(_dialogue_03)
func _on_dialogue_03_choice_made(_choice: int) -> void: _player.hud.start_dialogue.call_deferred(_dialogue_04)
func _on_dialogue_04_choice_made(_choice: int) -> void: _player.hud.start_dialogue.call_deferred(_dialogue_05)
func _on_dialogue_05_choice_made(_choice: int) -> void: _player.hud.start_dialogue.call_deferred(_dialogue_06)
func _on_dialogue_06_choice_made(_choice: int) -> void: _player.hud.start_dialogue.call_deferred(_final_dialogue)


func _on_final_dialogue_choice_made(choice: int) -> void:
	_player.input.set_enabled.call_deferred(false)
	
	await get_tree().create_timer(0.5).timeout
	
	match choice:
		_:
			Globals.day_ended.emit()
