extends Node3D


signal left
signal spawn_pacakge


const VENDOR_MENU_SCENE: PackedScene = preload("uid://diy715xds7cni")

@export var _head_marker: Node3D
@export var _profile_builder_upgrade: Upgrade
@export_group("Dialogue")
@export var _interact_dialogues: Array[DialogueData]
@export var _interact_no_profiles_dialogues: Array[DialogueData]
@export var _profiles_explain_dialogue: DialogueData
@export var _package_01_dialogue: DialogueData
@export var _package_02_dialogue: DialogueData
@export var _package_03_dialogue: DialogueData
@export var _pacakge_items: Array[ItemData]

var _package_mentioned: bool = false
var _times_spoken: int = 0


func _ready() -> void:
	for dialogue: DialogueData in _interact_dialogues:
		dialogue.choice_made.connect(_on_interact_dialouge_choice_made)
	
	for dialogue: DialogueData in _interact_no_profiles_dialogues:
		dialogue.choice_made.connect(_on_interact_no_profile_dialouge_choice_made)
	
	_package_01_dialogue.choice_made.connect(_on_package_01_choice_made)
	_package_02_dialogue.choice_made.connect(_on_package_choice_made)
	_package_03_dialogue.choice_made.connect(_on_package_choice_made)
	_package_03_dialogue.finished.connect(_pacakge_03_dialogue_finished)


func _on_interacted(player: Player) -> void:
	if _package_mentioned and Globals.time_of_day > 20.0:
		_package_mentioned = false
		player.hud.start_dialogue(_package_03_dialogue)
		player.update_look_position(_head_marker.global_position)
		return
	
	match _times_spoken:
		1: 
			_package_mentioned = true
			player.hud.start_dialogue(_package_01_dialogue)
		_: 
			if _profile_builder_upgrade.bought:
				player.hud.start_dialogue(_interact_dialogues.pick_random())
			else:
				player.hud.start_dialogue(_interact_no_profiles_dialogues.pick_random())
	
	_times_spoken += 1
	player.update_look_position(_head_marker.global_position)


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


func _on_interact_no_profile_dialouge_choice_made(choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	match choice:
		0: # Buying
			_open_vendor_menu(player, true)
		1: # Selling
			_open_vendor_menu(player, false)
		2: # Nevermind
			_on_vendor_menu_closed(player)


func _on_package_01_choice_made(_choice: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	player.hud.start_dialogue.call_deferred(_package_02_dialogue)


func _on_package_choice_made(choice: int) -> void:
	if not _profile_builder_upgrade.bought:
		_on_interact_no_profile_dialouge_choice_made(choice)
	else:
		_on_interact_dialouge_choice_made(choice)


func _pacakge_03_dialogue_finished() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	for item: ItemData in _pacakge_items:
		player.inventory.add_item(item)
		Globals.fish_collected.emit(item)


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


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if Globals.time_of_day > 22.0:
		left.emit()
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
		if _package_mentioned:
			spawn_pacakge.emit()
