extends Node3D


signal left


const VENDOR_MENU_SCENE: PackedScene = preload("uid://diy715xds7cni")

@export var _head_marker: Node3D
@export var _fishing_rod_upgrade: Upgrade
@export_group("Dialogue")
@export var _buy_fishing_rod_dialogue: DialogueData
@export var _bought_fishing_rod_dialogue: DialogueData
@export var _interact_dialogues: Array[DialogueData]
@export var _interact_no_profiles_dialogues: Array[DialogueData]
@export var _profiles_explain_dialogue: DialogueData

var _times_spoken: int = 0


func _on_interacted(player: Player) -> void:
	match _times_spoken:
		# Start dialogue when interacting with the vendor
		0: player.hud.start_dialogue(_buy_fishing_rod_dialogue)
		_: player.hud.start_dialogue(_interact_dialogues.pick_random())
	
	_times_spoken += 1
	player.update_look_position(_head_marker.global_position)


func _ready() -> void:
	_buy_fishing_rod_dialogue.choice_made.connect(_on_tutorial_dialouge_choice_made)
	for dialogue: DialogueData in _interact_dialogues:
		dialogue.choice_made.connect(_on_interact_dialouge_choice_made)


func _on_buy_fishing_rod_dialogue_finished() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	_on_interacted.call_deferred(player)


func _on_tutorial_dialouge_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		0: # Buying
			_open_vendor_menu(player, true)
		1: # Nevermind
			_on_vendor_menu_closed(player)


func _on_interact_dialouge_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		0: # Buying
			_open_vendor_menu(player, true)
		1: # Selling
			_open_vendor_menu(player, false)
		2: # Profiles
			player.hud.start_dialogue.call_deferred(_profiles_explain_dialogue)
		3: # Nevermind
			_on_vendor_menu_closed(player)


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
	if _fishing_rod_upgrade.bought and _times_spoken <= 1:
		player.hud.start_dialogue.call_deferred(_bought_fishing_rod_dialogue)
		return
	player.input.set_enabled.call_deferred(true)
	player.update_look_position(Vector3.ZERO)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if Globals.time_of_day > 22.0:
		left.emit()
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
