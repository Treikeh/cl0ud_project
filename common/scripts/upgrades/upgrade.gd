extends Resource
class_name Upgrade

@export var name: String = "Name"
@export var description: String = "Description"
@export var icon: Texture
@export var cost: int = 0

var bought: bool = false


@warning_ignore("unused_parameter")
func apply_upgrade(player: Player) -> void:
	pass
