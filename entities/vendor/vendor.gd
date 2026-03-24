extends Node3D


const VENDOR_MENU_SCENE: PackedScene = preload("uid://diy715xds7cni")


func _on_interact_area_3d_interacted(interactee: Player) -> void:
	var vendor_menu: Control = VENDOR_MENU_SCENE.instantiate().with_data(interactee.inventory)
	add_child(vendor_menu)
	vendor_menu.closed.connect(_on_vendor_menu_closed.bind(interactee))
	
	interactee.input.set_enabled(false)


func _on_vendor_menu_closed(interactee: Player) -> void:
	interactee.input.set_enabled(true)
