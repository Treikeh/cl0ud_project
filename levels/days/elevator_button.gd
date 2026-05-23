extends InteractArea3D


@onready var _collision_shape: CollisionShape3D = get_child(0)


func _ready() -> void:
	_collision_shape.disabled = true


func _process(_delta: float) -> void:
	if Globals.time_of_day > 20 and _collision_shape.disabled == true:
		_collision_shape.disabled = false
