extends Node3D


const PROFILE_MENU_SCENE: PackedScene = preload("uid://cg2ukppievp2t")


func _on_interacted(player: Player) -> void:
	player.input.set_enabled(false)
	
	var inv: Inventory = player.inventory
	var piece_inv: Inventory = player.piece_inventory
	var profile_menu: Control = PROFILE_MENU_SCENE.instantiate().with_data(inv, piece_inv)
	add_child(profile_menu)
	profile_menu.closed.connect(_on_menu_closed.bind(player))


func _on_menu_closed(player: Player) -> void:
	player.input.set_enabled.call_deferred(true)
	player.update_look_position(Vector3.ZERO)
