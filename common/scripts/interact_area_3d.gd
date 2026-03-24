extends Area3D
class_name InteractArea3D


signal interacted(interactee: Player)


@export var prompt: String = "Interact"


func interact(interactee: Player) -> void:
	interacted.emit(interactee)
