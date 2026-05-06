extends Node3D


@onready var _animation_player: AnimationPlayer = $AnimationPlayer



func open() -> void:
	_animation_player.play("open")


func close() -> void:
	_animation_player.play("close")
