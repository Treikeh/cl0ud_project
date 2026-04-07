extends RigidBody3D
class_name Player


var _minigame_look_dir: Vector2
var _look_position: Vector3

var input: PlayerInput
var movement: PlayerMovement
var inventory: Inventory
var hud: Hud


func _ready() -> void:
	Globals.fish_caught.connect(_on_fish_caught)
	Globals.fish_hooked.connect(_on_fish_hooked)
	Globals.fish_escaped.connect(_on_fish_escaped)
	
	_interact_ray.prompt_updated.connect(hud.update_interact_prompt)
	
	_load_save_data.call_deferred()


func _physics_process(delta: float) -> void:
	#NOTE: In physics process to stop the hook from freezing when the camera is moving.
	#TODO: Find a better way to handle the hook and line physics.
	if _look_position != Vector3.ZERO:
		_look_at_position(delta)


# Make the camera look at a point
func _look_at_position(delta: float) -> void:
	var dir_to_hook: Vector3 = _head.global_position.direction_to(_look_position)
	var look_dir: Vector2 = Vector2(
			atan2(-dir_to_hook.x, -dir_to_hook.z),
			dir_to_hook.dot(global_basis.y)
	)
	
	# Framerate independant lerp weight
	const LERP_FACTOR: float = 3.0
	var weight: float = 1.0 - exp(-LERP_FACTOR * delta)
	# Lerp orientation
	var desired_orientation: float = look_dir.x - _minigame_look_dir.x
	_orientation.rotation.y = lerp_angle(_orientation.rotation.y, desired_orientation, weight)
	# Lerp head angle
	var desired_head_angle: float = look_dir.y - _minigame_look_dir.y
	_head.rotation.x = lerp_angle(_head.rotation.x, desired_head_angle, weight)


func update_look_position(look_position: Vector3 = Vector3.ZERO) -> void:
	_look_position = look_position


func update_minigame_look_dir(minigame_look_dir: Vector2) -> void:
	_minigame_look_dir = minigame_look_dir


#region Input

@export_group("Input")
@export var _orientation: Node3D
@export var _head: Node3D
@export var _interact_ray: RayCast3D

var fishing_rod: Node3D


func _on_interacted() -> void:
	_interact_ray.try_interact()


func _on_jumped(jump_input: bool) -> void:
	movement.update_jumping(jump_input)


func _on_hook_thrown(throw_input: bool) -> void:
	if throw_input:
		fishing_rod.use_rod()
	else:
		fishing_rod.stop_use_rod()


func _on_hook_reeled(reel_input: bool) -> void:
	if reel_input:
		fishing_rod.reel_inn()


func _on_looked(look_input: Vector2) -> void:
	if _look_position != Vector3.ZERO:
		return
	
	_orientation.rotate_object_local(Vector3.UP, -deg_to_rad(look_input.x))
	_head.rotate_object_local(Vector3.RIGHT, -deg_to_rad(look_input.y))
	_head.rotation.x = clampf(_head.rotation.x, deg_to_rad(-89.0), deg_to_rad(89))


func _on_moved(move_input: Vector2) -> void:
	var move_dir: Vector3 = _orientation.global_basis * Vector3(move_input.x, 0.0, move_input.y).normalized()
	movement.update_move_dir(move_dir)

#endregion


#region UI

const INVENTORY_SCENE: PackedScene = preload("uid://6lg7o50gd213")
const MINIGMAES_SCENE: PackedScene = preload("uid://cge1q8m11mo65")
const PAUSE_SCENE: PackedScene = preload("uid://c0fsgd03bj03a")


func _on_inventory_opened() -> void:
	input.set_enabled(false)
	
	# Spawn inventory
	var inventory_menu: Control = INVENTORY_SCENE.instantiate().with_data(inventory)
	add_child(inventory_menu)
	inventory_menu.closed.connect(_on_inventory_closed)

func _on_inventory_closed() -> void:
	# call_deffered to avoid having the inventory close in the same frame it's opened
	input.set_enabled.call_deferred(true)


func _on_pause_opened() -> void:
	input.set_enabled(false)
	
	# Spawn pause menu
	var pause_menu: Control = PAUSE_SCENE.instantiate()
	add_child(pause_menu)
	pause_menu.closed.connect(_on_pause_closed)

func _on_pause_closed() -> void:
	input.set_enabled(true)

#endregion


#region Fishing

func _on_fish_hooked() -> void:
	input.set_enabled(false)
	
	var minigames_root: Control = MINIGMAES_SCENE.instantiate().with_data(self)
	add_child(minigames_root)


func _on_fish_caught() -> void:
	input.set_enabled(true)
	fishing_rod.fish_caught()
	update_look_position(Vector3.ZERO)


func _on_fish_escaped() -> void:
	input.set_enabled(true)
	fishing_rod.fish_escaped()
	update_look_position(Vector3.ZERO)

#endregion


#region save/load

const SAVE_DATA_KEY: String = "player"

func get_save_data() -> Dictionary:
	var data: Dictionary = {
		SAVE_DATA_KEY: {
			"position": var_to_str(global_position),
			"head_rotation": var_to_str(_head.rotation_degrees.x),
			"orientation": var_to_str(_orientation.rotation_degrees.y),
			"inventory": inventory.get_save_data()
		},
	}
	return data

func _load_save_data() -> void:
	# Load and set save data
	var data: Dictionary = SaveManager.get_save_data(SAVE_DATA_KEY)
	if data.is_empty():
		return
	
	# Update position
	global_position = str_to_var(data.position)
	# Update rotation
	_orientation.rotation_degrees.y = str_to_var(data.orientation)
	_head.rotation_degrees.x = str_to_var(data.head_rotation)
	# Update inventory
	inventory.load_save_data(data.inventory)

#endregion
