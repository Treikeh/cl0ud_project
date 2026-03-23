extends Control



@export_group("Minigames")
@export var minigames_root: Control

var _player: Player


func with_data(player: Player) -> Control:
	_player = player
	return self


func _ready() -> void:
	minigames_root.reel_inn_minigame.player = _player
	
	_player.fish_hooked.connect(minigames_root.start_minigames)
