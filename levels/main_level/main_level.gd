extends Node3D


@export var _days: Node3D
@export var _day_night_cycle: DayNightCycle

#NOTE: Day 1 has the value of 0, similar to how arrays start at 0
var current_day: int = 0


func _ready() -> void:
	_load_save_data()


func change_day(new_day: int) -> void:
	# Enable current day and disable all other
	for i: int in _days.get_child_count():
		var day: Node3D = _days.get_child(i)
		if new_day == i:
			day.show()
			day.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			day.hide()
			day.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Update current day settings
	current_day = new_day



#region save/load

const SAVE_DATA_KEY: String = "main_level"

func get_save_data() -> Dictionary:
	var data: Dictionary = {
		SAVE_DATA_KEY: {
			"current_day": current_day,
		},
	}
	return data

func _load_save_data() -> void:
	# Load and set save data
	var data: Dictionary = SaveManager.get_save_data(SAVE_DATA_KEY)
	if not data.is_empty():
		current_day = data.current_day
	
	change_day(current_day)

#endregion
