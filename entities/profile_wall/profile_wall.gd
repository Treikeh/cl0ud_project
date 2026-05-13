extends Node3D


const PROFILE_MENU_SCENE: PackedScene = preload("uid://cg2ukppievp2t")
var _profiles: Array[ProfileData] = []


func _ready() -> void:
	_load_profiles()


func _on_interacted(player: Player) -> void:
	player.input.set_enabled(false)
	
	var inv: Inventory = player.inventory
	var piece_inv: Inventory = player.piece_inventory
	var profile_menu: Control = PROFILE_MENU_SCENE.instantiate().with_data(inv, piece_inv, _profiles)
	add_child(profile_menu)
	profile_menu.closed.connect(_on_menu_closed.bind(player))


func _on_menu_closed(player: Player) -> void:
	player.input.set_enabled.call_deferred(true)
	player.update_look_position(Vector3.ZERO)


func _load_profiles() -> void:
	const PATH: String = "res://common/data/profiles/"
	var files: PackedStringArray = ResourceLoader.list_directory(PATH)
	for file: String in files:
		if file.ends_with(".tres"):
			var profile: ProfileData = load(PATH + file)
			_profiles.append(profile)
