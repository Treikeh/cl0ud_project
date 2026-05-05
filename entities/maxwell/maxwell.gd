extends Node3D


@export var _anim: AnimationPlayer


func _on_interact_area_3d_interacted(_player: Player) -> void:
	if not _anim.is_playing():
		_anim.play("pet")
