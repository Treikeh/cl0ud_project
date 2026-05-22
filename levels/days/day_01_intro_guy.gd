extends Node3D


@export var _trigger_dialogue: DialogueData
@export var _old_man_dialogue: DialogueData
@export var _head_marker: Node3D
@export var _interact_collision: CollisionShape3D

@export_group("Interact Dialogue")
@export var _interact_dialogue: DialogueData
@export var _otto_dialogue: DialogueData
@export var _intercept_dialogue: DialogueData
@export var _ok_dialogue: DialogueData
@export var _repeat_dialogue: DialogueData

var _has_spoken: bool = false
var _times_spoken: int = 0


func _ready() -> void:
	_trigger_dialogue.choice_made.connect(_on_trigger_dialogue_choice_made)
	
	_interact_dialogue.choice_made.connect(_on_interact_dialogue_choice_made)
	
	Globals.day_01_spoken_to_old_man.connect(func(): _interact_collision.disabled = false)


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


func _on_interact(player: Player) -> void:
	match _times_spoken:
		0: player.hud.start_dialogue(_interact_dialogue)
		_: player.hud.start_dialogue(_repeat_dialogue)
	
	_times_spoken += 1
	player.update_look_position(_head_marker.global_position)


func _on_interact_dialogue_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		0: player.hud.start_dialogue.call_deferred(_otto_dialogue)
		1: player.hud.start_dialogue.call_deferred(_intercept_dialogue)
		2: player.hud.start_dialogue.call_deferred(_ok_dialogue)
