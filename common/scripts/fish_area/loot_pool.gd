extends Resource
class_name LootPool


@export var _min_value: int = 0
@export var _max_value: int = 10
@export_file("*tscn") var _fish_data: Array[String] = []


func get_value() -> int:
	return randi_range(_min_value, _max_value)
