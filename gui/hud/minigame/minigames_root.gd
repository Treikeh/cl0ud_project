extends Control


signal minigames_failed
signal minigames_succeeded


@export var _catch_minigame: Control
@export var reel_inn_minigame: Control


func _ready() -> void:
	_catch_minigame.succeeded.connect(_on_catch_minigame_succeeded)
	_catch_minigame.failed.connect(_on_minigames_failed)
	
	reel_inn_minigame.succeeded.connect(_on_reel_in_minigame_succeeded)
	reel_inn_minigame.failed.connect(_on_minigames_failed)


func start_minigames() -> void:
	_catch_minigame.process_mode = Node.PROCESS_MODE_INHERIT
	_catch_minigame.start_minigame()


func _end_minigames() -> void:
	# End both minigames
	_catch_minigame.end_minigame()
	reel_inn_minigame.end_minigame()



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
