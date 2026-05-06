extends Node3D


@onready var main_level: MainLevel = find_child("MainLevel")


func _end_day(player: Player) -> void:
	$Interactable/ElevatorDoor.close()
	
	await _spawn_sleep_menu().fadded_inn
	
	main_level.end_day(player)


func _spawn_sleep_menu() -> CanvasLayer:
	var sleep_menu_scene: PackedScene = load("res://gui/sleep_menu/sleep_menu.tscn")
	var sleep_menu: CanvasLayer = sleep_menu_scene.instantiate()
	get_tree().root.add_child(sleep_menu)
	return sleep_menu
