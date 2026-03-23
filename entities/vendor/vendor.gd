extends Node3D


@export var _vendor_menu: Control


func _ready() -> void:
	_vendor_menu.hide()


func _on_interact_area_3d_interacted(interactee: Node3D) -> void:
	_vendor_menu.open(interactee.inventory)
