extends Marker3D


const CART_SCENE: PackedScene = preload("uid://cajkq10x4643")


@export var _schedule: Array[float]

var _spawned_carts: Array[bool]


func _ready() -> void:
	for i: int in _schedule.size():
		_spawned_carts.append(false)


func _process(_delta: float) -> void:
	for i: int in _schedule.size():
		var time: float = _schedule[i]
		if Globals.time_of_day > time and _spawned_carts[i] == false:
			_spawned_carts[i] = true
			_spawn_cart()


func _spawn_cart() -> void:
	var cart: Node3D = CART_SCENE.instantiate()
	add_child(cart)
