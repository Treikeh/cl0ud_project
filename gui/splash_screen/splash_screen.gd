extends Control


func _ready() -> void:
	var level: String = get_current_level()
	$Label.text = "Now entering: %s" % level
	
	await get_tree().create_timer(2.0).timeout
	
	LevelManager.load_level(level)


func get_current_level() -> String:
	var data: Dictionary = SaveManager.get_save_data("glboals")
	if data.is_empty():
		return "res://levels/days/day_01.tscn"
	return data.current_level
