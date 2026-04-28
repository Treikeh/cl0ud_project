extends Node3D


const PRINTER_MENU_SCENE: PackedScene = preload("uid://daoulaw7h8y4p")


var paper_ready: bool = false
var paper_item: ItemData


func _ready() -> void:
	$PaperMesh.hide()


func _on_interact_area_3d_interacted(player: Player) -> void:
	if paper_ready:
		print(paper_item.name)
		player.piece_inventory.add_item(paper_item)
		$PaperMesh.hide()
	else:
		player.input.set_enabled(false)
		
		var profile_menu: Control = PRINTER_MENU_SCENE.instantiate().with_data(player.inventory)
		add_child(profile_menu)
		profile_menu.closed.connect(_on_profile_menu_closed.bind(player))
		profile_menu.fish_printed.connect(_on_profile_menu_fish_printed)


func _on_profile_menu_closed(player: Player) -> void:
	player.input.set_enabled.call_deferred(true)
	player.update_look_position(Vector3.ZERO)


func _on_profile_menu_fish_printed(item_data: ItemData) -> void:
	paper_item = item_data
	print(item_data.name)
	paper_ready = true
	$PaperMesh.show()
