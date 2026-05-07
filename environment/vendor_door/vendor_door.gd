extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func close() -> void:
	animation_player.play("close")
	$CloseSfx.play_one_shot()
