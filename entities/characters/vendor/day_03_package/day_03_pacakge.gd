extends Node3D


@export var _pacakge_items: Array[ItemData]


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func make_active() -> void:
	show()
	process_mode = Node.PROCESS_MODE_INHERIT


func _on_interact_area_3d_interacted(player: Player) -> void:
	for item: ItemData in _pacakge_items:
		player.inventory.add_item(item)
		Globals.fish_collected.emit(item)
	
	queue_free()
