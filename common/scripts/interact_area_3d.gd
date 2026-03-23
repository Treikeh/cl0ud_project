extends Area3D
class_name InteractArea3D


signal interacted(interactee: Node3D)


@export var prompt: String = "Interact"


func interact(interactee: Node3D) -> void:
	interacted.emit(interactee)
