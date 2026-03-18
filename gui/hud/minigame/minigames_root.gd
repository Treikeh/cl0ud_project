extends Control


signal minigames_failed
signal minigames_succeeded


@export var _catch_minigame: Control
@export var _reel_inn_minigame: Control


func _ready() -> void:
	_catch_minigame.succeeded.connect(_on_catch_minigame_succeeded)
	_catch_minigame.failed.connect(_on_minigames_failed)
	
	_reel_inn_minigame.succeeded.connect(_on_reel_in_minigame_succeeded)
	_reel_inn_minigame.failed.connect(_on_minigames_failed)
	
	#_end_minigames()


func start_minigames() -> void:
	_catch_minigame.process_mode = Node.PROCESS_MODE_INHERIT
	_catch_minigame.start_minigame()


func _end_minigames() -> void:
	# End both minigames
	_catch_minigame.end_minigame()
	_reel_inn_minigame.end_minigame()
	
	#await get_tree().create_timer(1.0).timeout
	#start_minigames()



func _on_catch_minigame_succeeded() -> void:
	# End catch minigame
	_catch_minigame.end_minigame()
	# Start reel inn minigame
	_reel_inn_minigame.start_minigame()


func _on_reel_in_minigame_succeeded() -> void:
	_end_minigames()
	minigames_succeeded.emit()
	Globals.fish_caught.emit()


func _on_minigames_failed() -> void:
	_end_minigames()
	minigames_failed.emit()
