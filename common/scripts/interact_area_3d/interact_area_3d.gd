extends Area3D
class_name InteractArea3D


signal interacted_no_player
signal interacted(player: Player)


@export var prompt: String = "Interact"


func interact(player: Player) -> void:
	interacted.emit(player)
	interacted_no_player.emit()
