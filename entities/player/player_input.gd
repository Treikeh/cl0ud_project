extends Node
class_name PlayerInput


signal interacted
signal inventory_opened
signal jumped(jump_input: bool)
signal hook_thrown(throw_input: bool)
signal hook_reeled(reel_input: bool)
signal looked(look_input: Vector2)
signal moved(move_input: Vector2)


@export var _camera_sens: float = 0.1

var _enabled: bool = true

@onready var _player: Player = get_owner()


func _ready() -> void:
	_player.input = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Connect signals
	interacted.connect(_player._on_interacted)
	inventory_opened.connect(_player._on_inventory_opened)
	
	jumped.connect(_player._on_jumped)
	hook_thrown.connect(_player._on_hook_thrown)
	hook_reeled.connect(_player._on_hook_reeled)
	
	looked.connect(_player._on_looked)
	moved.connect(_player._on_moved)


func _input(event: InputEvent) -> void:
	if not _enabled:
		looked.emit(Vector2.ZERO)
		moved.emit(Vector2.ZERO)
		return
	
	# Interact input
	if event.is_action_pressed("interact"):
		interacted.emit()
	
	# Inventory
	if event.is_action_pressed("inventory"):
		inventory_opened.emit()
	
	# Jump input
	if event.is_action_pressed("jump"):
		jumped.emit(true)
	elif event.is_action_released("jump"):
		jumped.emit(false)
	
	# Primary fire
	if event.is_action_pressed("throw_hook"):
		hook_thrown.emit(true)
	elif event.is_action_released("throw_hook"):
		hook_thrown.emit(false)
	
	# Secondary fire
	if event.is_action_pressed("reel_hook"):
		hook_reeled.emit(true)
	elif event.is_action_released("reel_hook"):
		hook_reeled.emit(false)
	
	# Look input
	if event is InputEventMouseMotion:
		var look_input: Vector2 = event.relative * _camera_sens
		looked.emit(look_input)
	
	# Move input
	var move_input: Vector2 = Input.get_vector("move_l", "move_r", "move_f", "move_b")
	moved.emit(move_input)


#region Public

func set_enabled(enable: bool) -> void:
	_enabled = enable

func is_enabled() -> bool:
	return _enabled

#endregion
