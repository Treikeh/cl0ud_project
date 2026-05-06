extends Node3D


@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	open()


func open() -> void:
	_animation_player.play("open")


func close() -> void:
	_animation_player.play("close")
