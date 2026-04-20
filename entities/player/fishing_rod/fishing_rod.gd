extends Node3D
class_name FishingRod


enum FishingState {
	IDLE,
	READY_THROW,
	WAITING,
	FISH_HOOKED,
	REEL_IN,
}


@export var _rod_mesh: Node3D
@export var _hook: FishingHook
@export var _hook_throw_pos: Marker3D
@export var _balance_vars: FishingVariables

@export_group("Hook line")
@export var _pin_joint: PinJoint3D
@export var _pin_anchor: StaticBody3D
@export var _fishing_line: MeshInstance3D
@export var _fishing_line_mat: Material

@export_group("SFX")
@export var _cast_sfx: FmodEventEmitter3D
@export var _reel_sfx: FmodEventEmitter3D
@export var _caught_sfx: FmodEventEmitter3D
@export var _escaped_sfx: FmodEventEmitter3D

var _throw_charge: float = 0.0
var _throw_charge_time: float = 0.0
var _throw_pos: Vector3
var _fishing_state: FishingState = FishingState.IDLE

@onready var _player: Player = get_owner()
@onready var _line_mesh: ImmediateMesh = _fishing_line.mesh


func _ready() -> void:
	_player.fishing_rod = self
	
	_hook.hook_hit_water.connect(_on_hook_hit_water)
	
	Globals.fish_hooked.connect(_on_fish_hooked)
	Globals.fish_escaped.connect(_on_fish_escaped)
	Globals.fish_caught.connect(_on_fish_caught)


func _process(delta: float) -> void:
	if _fishing_state == FishingState.READY_THROW and _throw_charge_time < 1.0:
		var charge_speed: float = _balance_vars.throw_charge_speed
		_throw_charge_time += delta * charge_speed
		
		var charge_curve: Curve = _balance_vars.throw_charge_curve
		_throw_charge = charge_curve.sample(_throw_charge_time)
	
	if _fishing_state == FishingState.FISH_HOOKED:
		_player.update_look_position(_hook.global_position)
	
	#NOTE: call_deferred to avoid the line being 1 frame late when using a controller to look around
	_display_fishing_line.call_deferred()
	
	_rod_mesh.fishing_state = _fishing_state
	_rod_mesh.throw_charge = _throw_charge
	_rod_mesh.fish_dir = _player._minigame_look_dir


func _physics_process(_delta: float) -> void:
	if _fishing_state == FishingState.REEL_IN:
		var launch_dir: Vector3 = _hook.global_position.direction_to(global_position) + (Vector3.UP * 0.15)
		var launch_force: float = _hook.global_position.distance_to(global_position) * 0.75
		_hook.apply_central_force(launch_dir * launch_force)
		if _hook.global_position.distance_squared_to(global_position) <= 25.0:
			_reset_rod()


func _display_fishing_line() -> void:
	_line_mesh.clear_surfaces()
	_line_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, _fishing_line_mat)
	# End point
	_line_mesh.surface_add_vertex(_hook.global_position + _hook.global_basis.x * 0.02)
	_line_mesh.surface_add_vertex(_hook.global_position - _hook.global_basis.x * 0.02)
	
	# Start point
	_line_mesh.surface_add_vertex(_pin_anchor.global_position + global_basis.x * 0.02)
	_line_mesh.surface_add_vertex(_pin_anchor.global_position - global_basis.x * 0.02)
	
	_line_mesh.surface_end()


func _ready_rod() -> void:
	_fishing_state = FishingState.READY_THROW
	Globals.started_fishing.emit()


func _throw_hook() -> void:
	_throw_pos = global_position
	_fishing_state = FishingState.WAITING
	
	# Disconnect hook from pin
	_pin_joint.node_b = _pin_anchor.get_path()
	_hook.top_level = true
	_hook.linear_damp = 0.0
	_hook.hook_state = FishingHook.HookState.THROWN
	
	_fishing_state = FishingState.WAITING
	
	
	await get_tree().physics_frame
	_hook.global_position = _hook_throw_pos.global_position
	# Launch hook
	var throw_force: float = _balance_vars.base_throw_force
	# Add upgrade force
	throw_force += _balance_vars.throw_force_upgrade_curve.sample(_player.throw_upgrade_level)
	# Multiply by charge amount
	throw_force *= _throw_charge
	const UPWARDS_FORCE: Vector3 = Vector3.UP * 0.4
	var throw_dir: Vector3 = -global_basis.z + UPWARDS_FORCE
	_hook.set_axis_velocity(throw_dir * throw_force)
	_throw_charge_time = 0.0
	
	#SFX
	_cast_sfx.play_one_shot()


func _reel_inn() -> void:
	_fishing_state = FishingState.REEL_IN
	var launch_dir: Vector3 = _hook.global_position.direction_to(global_position)
	var launch_force: float = _hook.global_position.distance_to(global_position)
	_hook.hook_state = FishingHook.HookState.NORMAL
	_hook.set_axis_velocity(launch_dir * launch_force)


func _reset_rod() -> void:
	_throw_charge = 0.0
	_fishing_state = FishingState.IDLE
	
	# Reset hook
	_hook.reset_hook()
	
	# Reconnect hook to pin
	var hook_offset: Vector3 = -_pin_anchor.global_basis.y * 0.3
	_hook.global_position = _pin_anchor.global_position + hook_offset
	_pin_joint.node_b = _hook.get_path()
	
	#SFX
	_reel_sfx.play_one_shot()
	Globals.stopped_fishing.emit()


func _collect_fish() -> void:
	Globals.fish_collected.emit(_hook.hooked_fish.item_data)
	_player.inventory.add_item(_hook.hooked_fish.item_data)
	_hook.hooked_fish.queue_free()


func _on_hook_hit_water() -> void:
	Globals.hook_distance = _throw_pos.distance_squared_to(_hook.global_position)


func _on_fish_hooked() -> void:
	if _fishing_state == FishingState.WAITING:
		_fishing_state = FishingState.FISH_HOOKED


func _on_fish_caught() -> void:
	_reel_inn()
	
	_hook.spawn_fish()
	
	#SFX
	_caught_sfx.play_one_shot()


func _on_fish_escaped() -> void:
	if _fishing_state == FishingState.FISH_HOOKED:
		_fishing_state = FishingState.WAITING
		
		#SFX
		_escaped_sfx.play_one_shot()


#region Public

func use_rod() -> void:
	if _fishing_state == FishingState.IDLE:
		if _hook.hooked_fish != null:
			_collect_fish()
		else:
			_ready_rod()

func stop_use_rod() -> void:
	if _fishing_state == FishingState.READY_THROW:
		_throw_hook()


func reel_inn() -> void:
	if _fishing_state != FishingState.IDLE:
		_reel_inn()

func stop_reel_inn() -> void:
	pass

#endregion
