extends Node3D


@export var _play_prompt: String = "Play"
@export var _pause_prompt: String = "Pause"
@export var _audio_emitter: FmodEventEmitter3D
@export var _interact_area: InteractArea3D

var _is_playing: bool = true


func _ready() -> void:
	_interact_area.prompt = _pause_prompt


func _on_interacted(_player: Player) -> void:
	if _is_playing:
		_is_playing = false
		_audio_emitter.paused = true
		_interact_area.prompt = _play_prompt
		print("Pause")
	else:
		_is_playing = true
		_audio_emitter.paused = false
		_interact_area.prompt = _pause_prompt
		print("Play")
