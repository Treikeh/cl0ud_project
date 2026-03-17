extends RayCast3D


@onready var _player: Player = get_owner()


func try_interact() -> void:
	var collider: Node3D = get_collider()
	if collider is InteractArea3D:
		collider.interact(_player)
