extends Node3D


@export_file("*.tscn") var _next_day: String
@export var _day_night_cycle: DayNightCycle


func _ready() -> void:
	_load_save_data()


func end_day(player: Player) -> void:
	_day_night_cycle.set_time_of_day(_day_night_cycle.day_start)
	SaveManager.save_game()
	LevelManager.load_level(_next_day)


#region save/load

const SAVE_DATA_KEY: String = "level"

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
