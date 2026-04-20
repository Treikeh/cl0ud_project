extends Node3D


const VENDOR_MENU_SCENE: PackedScene = preload("uid://diy715xds7cni")

@export var _head_marker: Marker3D
@export var _interact_dialogue: Array[DialogueData] = []
@export var _nevermind_dialogue: Array[DialogueData] = []
@export var _close_shop_dialogue: Array[DialogueData] = []


func _on_interact_area_3d_interacted(player: Player) -> void:
	# Start dialogue when interacting with the vendor
	player.update_look_position(_head_marker.global_position)
	var dialogue: Control = player.hud.start_dialogue(_interact_dialogue)
	dialogue.dialouge_choice_made.connect(_on_dialouge_choice_made.bind(player))


func _on_dialouge_choice_made(choice: int, player: Player) -> void:
	match choice:
		0: # Buying?
			_open_vendor_menu(player, true)
		1: # Selling
			_open_vendor_menu(player, false)
		2: # Nevermind
			_on_vendor_menu_closed(player)
			#player.hud.start_dialogue.call_deferred(_nevermind_dialogue)


func _open_vendor_menu(player: Player, buy: bool) -> void:
	var vendor_menu: Control = VENDOR_MENU_SCENE.instantiate().with_data(player.inventory, buy)
	add_child(vendor_menu)
	vendor_menu.closed.connect(_on_vendor_menu_closed.bind(player))
	
	# Disable input
	#NOTE: call_deferred to disable the input after the hud reenables it when the dialogue ends
	player.input.set_enabled.call_deferred(false)
	# Make the player look at the head of the vendor
	player.update_look_position(_head_marker.global_position)


func _on_vendor_menu_closed(player: Player) -> void:
	player.input.set_enabled.call_deferred(true)
	player.update_look_position(Vector3.ZERO)
	#player.hud.start_dialogue.call_deferred(_close_shop_dialogue)
