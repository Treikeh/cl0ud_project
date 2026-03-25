extends Control


signal minigames_failed
signal minigames_succeeded


@export var _catch_minigame: Control
@export var reel_inn_minigame: Control

var _player: Player


func with_data(player: Player) -> Control:
	_player = player
	return self


func _ready() -> void:
	_catch_minigame.succeeded.connect(_on_catch_minigame_succeeded)
	_catch_minigame.failed.connect(_on_minigames_failed)
	
	reel_inn_minigame.player = _player
	reel_inn_minigame.succeeded.connect(_on_reel_in_minigame_succeeded)
	reel_inn_minigame.failed.connect(_on_minigames_failed)
	
	_start_minigames()


func _start_minigames() -> void:
	_catch_minigame.process_mode = Node.PROCESS_MODE_INHERIT
	_catch_minigame.start_minigame()
	# Disable player input
	#_player.input.set_enabled(false)


func _end_minigames() -> void:
	# End both minigames
	_catch_minigame.end_minigame()
	reel_inn_minigame.end_minigame()
	# Enable player input
	_player.input.set_enabled(true)



func _on_catch_minigame_succeeded() -> void:
	# End catch minigame
	_catch_minigame.end_minigame()
	# Start reel inn minigame
	reel_inn_minigame.start_minigame()


func _on_reel_in_minigame_succeeded() -> void:
	_end_minigames()
	minigames_succeeded.emit()


func _on_minigames_failed() -> void:
	_end_minigames()
	minigames_failed.emit()
