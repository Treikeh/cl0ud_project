extends RigidBody3D
class_name Player


var minigame_look_dir: Vector2

var input: PlayerInput
var movement: PlayerMovement
var inventory: Inventory


func _ready() -> void:
	_spawn_hud()


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
	_orientation.rotate_object_local(Vector3.UP, -deg_to_rad(look_input.x))
	_head.rotate_object_local(Vector3.RIGHT, -deg_to_rad(look_input.y))
	_head.rotation.x = clampf(_head.rotation.x, deg_to_rad(-89.0), deg_to_rad(89))


func _on_moved(move_input: Vector2) -> void:
	var move_dir: Vector3 = _orientation.global_basis * Vector3(move_input.x, 0.0, move_input.y).normalized()
	movement.update_move_dir(move_dir)

#endregion


#region UI

const HUD_SCENE: PackedScene = preload("res://gui/hud/hud.tscn")
const INVENTORY_SCENE: PackedScene = preload("uid://6lg7o50gd213")
const MINIGMAES_SCENE: PackedScene = preload("uid://cge1q8m11mo65")

var hud: Control

func _spawn_hud() -> void:
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	
	_interact_ray.prompt_updated.connect(hud.update_interact_prompt)


func _on_inventory_opened() -> void:
	input.set_enabled(false)
	
	# Spawn inventory
	var inventory_menu: Control = INVENTORY_SCENE.instantiate().with_data(inventory)
	add_child(inventory_menu)
	inventory_menu.closed.connect(_on_inventory_closed)


func _on_inventory_closed() -> void:
	# call_deffered to avoid having the inventory close in the same frame it's opened
	input.set_enabled.call_deferred(true)

#endregion


#region Fishing

func _on_fish_hooked() -> void:
	input.set_enabled(false)
	
	var minigames_root: Control = MINIGMAES_SCENE.instantiate().with_data(self)
	add_child(minigames_root)
	
	minigames_root.minigames_succeeded.connect(_on_fish_caught)
	minigames_root.minigames_failed.connect(_on_fish_escaped)


func _on_fish_caught() -> void:
	input.set_enabled(true)
	fishing_rod.fish_caught()


func _on_fish_escaped() -> void:
	input.set_enabled(true)
	fishing_rod.fish_escaped()


func _on_look_at_hook(look_dir: Vector2, delta: float) -> void:
	var desired_orientation_angle: float = look_dir.x - minigame_look_dir.x
	_orientation.rotation.y = lerp_angle(_orientation.rotation.y, desired_orientation_angle, 3.0 * delta)
	
	var desired_head_angle: float = look_dir.y - minigame_look_dir.y
	_head.rotation.x = lerp_angle(_head.rotation.x, desired_head_angle, 3.0 * delta)

#endregion
