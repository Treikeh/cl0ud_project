extends Control


@export_group("Minigames")
@export var _minigames_root: Control


func _ready() -> void:
	Globals.fish_hooked.connect(_minigames_root.start_minigames)
