extends Node3D
class_name MainLevel


@export_file("*.tscn") var _next_day: String
@export var _day_night_cycle: DayNightCycle
@export var _player_marker: Marker3D
@export var _junk_curve: Curve


func _ready() -> void:
	_load_save_data()


func end_day(_player: Player) -> void:
	# Reset day/night cycle
	_day_night_cycle.set_time_of_day(_day_night_cycle.day_start)
	
	# Reset position of player
	var player: Player = get_tree().get_first_node_in_group("player")
	player.global_position = _player_marker.global_position
	player._orientation.rotation_degrees = Vector3.ZERO
	player._head.rotation_degrees = Vector3.ZERO
	
	#NOTE: Level is being loaded before the game is saved because we want to save the new level -> 
	# <- not the current level.
	LevelManager.load_level(_next_day)
	SaveManager.save_game()


func _process(_delta: float) -> void:
	Globals.junk_fish_chance = _junk_curve.sample(_day_night_cycle.get_time_of_day())


#region save/load

const SAVE_DATA_KEY: String = "main_level"

func get_save_data() -> Dictionary:
	var data: Dictionary = {
		SAVE_DATA_KEY: {
			"time_of_day": _day_night_cycle.get_time_of_day()
		},
	}
	return data

func _load_save_data() -> void:
	# Load and set save data
	var data: Dictionary = SaveManager.get_save_data(SAVE_DATA_KEY)
	if not data.is_empty():
		_day_night_cycle.set_time_of_day(data.time_of_day)


#endregion
