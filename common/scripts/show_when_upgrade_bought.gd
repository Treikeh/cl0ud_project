extends Node3D


@export var _upgrade: Upgrade

func _process(_delta: float) -> void:
	visible = _upgrade.bought
