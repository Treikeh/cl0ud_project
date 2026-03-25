extends Node3D


const VENDOR_MENU_SCENE: PackedScene = preload("uid://diy715xds7cni")

@export var _head_marker: Marker3D
@export var _dialogue: Array[DialogueData] = []


func _on_interact_area_3d_interacted(player: Player) -> void:
	player.update_look_position(_head_marker.global_position)
	var dialogue: Control = player.hud.start_dialogue(_dialogue)
	dialogue.dialogue_ended.connect(_on_dialogue_ended.bind(player))


func _on_dialogue_ended(player: Player) -> void:
	var vendor_menu: Control = VENDOR_MENU_SCENE.instantiate().with_data(player.inventory)
	add_child(vendor_menu)
	vendor_menu.closed.connect(_on_vendor_menu_closed.bind(player))
	
	# Disable input
	#NOTE: call_deferred to disable the input after the hud reenables it when the dialogue ends
	player.input.set_enabled.call_deferred(false)
	# Make the player look at the head of the vendor
	player.update_look_position(_head_marker.global_position)


func _on_vendor_menu_closed(player: Player) -> void:
	# Enable input
	player.input.set_enabled(true)
	# Allow the player look around
	player.update_look_position(Vector3.ZERO)
