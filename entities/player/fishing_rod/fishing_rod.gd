extends Node3D
class_name FishingRod


enum FishingState {
	IDLE,
	READY_THROW,
	WAITING,
	FISH_HOOKED,
}


@export var _rod_mesh: Node3D
@export var _hook: FishingHook
@export var _hook_throw_pos: Marker3D
@export var _balance_vars: FishingVariables
@export var _distance_label: Label3D
@export var _hook_transform: RemoteTransform3D

@export_group("Hook line")
@export var _fishing_line: MeshInstance3D
@export var _rod_tip: Node3D
@export var _fishing_line_mat: Material
@export var _hook_los_check: RayCast3D

@export_group("SFX")
@export var _cast_sfx: FmodEventEmitter3D
@export var _reel_sfx: FmodEventEmitter3D
@export var _caught_sfx: FmodEventEmitter3D
@export var _escaped_sfx: FmodEventEmitter3D

var _throw_charge: float = 0.0
var _throw_charge_time: float = 0.0
var _throw_pos: Vector3

@onready var _player: Player = get_owner()
@onready var _line_mesh: ImmediateMesh = _fishing_line.mesh
@onready var _state_machine := StateMachine.new({
	FishingState.IDLE: {StateMachine.ENTER: _enter_idle},
	FishingState.READY_THROW: {StateMachine.ENTER: _enter_ready_throw, StateMachine.PROCESS: _process_ready_throw},
	FishingState.WAITING: {StateMachine.ENTER: _enter_waiting, StateMachine.PROCESS: _process_waiting},
	FishingState.FISH_HOOKED: {StateMachine.ENTER: _enter_fish_hooked, StateMachine.PROCESS: _process_fish_hooked}
})


func _ready() -> void:
	_player.fishing_rod = self
	
	_hook.hook_hit_water.connect(_on_hook_hit_water)
	
	Globals.fish_hooked.connect(_on_fish_hooked)
	Globals.fish_escaped.connect(_on_fish_escaped)
	Globals.fish_caught.connect(_on_fish_caught)
	
	_state_machine.switch(FishingState.IDLE)


func _process(delta: float) -> void:
	_state_machine.process(delta)
	_hook_los_check.target_position = _hook_los_check.to_local(_hook.global_position)
	
	#NOTE: call_deferred to avoid the line being 1 frame late when using a controller to look around
	_display_fishing_line.call_deferred()
	
	_rod_mesh.fishing_state = _state_machine.get_current_state()
	_rod_mesh.throw_charge = _throw_charge
	_rod_mesh.fish_dir = _player._minigame_look_dir


func _display_fishing_line() -> void:
	_line_mesh.clear_surfaces()
	_line_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, _fishing_line_mat)
	# End point
	_line_mesh.surface_add_vertex(_hook.global_position + _hook.global_basis.x * 0.02)
	_line_mesh.surface_add_vertex(_hook.global_position - _hook.global_basis.x * 0.02)
	
	# Start point
	_line_mesh.surface_add_vertex(_rod_tip.global_position + global_basis.x * 0.02 * 0.1)
	_line_mesh.surface_add_vertex(_rod_tip.global_position - global_basis.x * 0.02 * 0.1)
	
	_line_mesh.surface_end()


func _ready_rod() -> void:
	if visible:
		_state_machine.switch(FishingState.READY_THROW)


func _throw_hook() -> void:
	_state_machine.switch(FishingState.WAITING)


func _reel_inn() -> void:
	_state_machine.switch(FishingState.IDLE)


func _reset_rod() -> void:
	_throw_charge = 0.0
	
	# Reset hook
	_hook.reset_hook()
	
	# Reconnect hook to pin
	_hook.position = Vector3.ZERO
	_hook.rotation_degrees = Vector3(180, 0.0, 0.0)
	_hook.process_mode = Node.PROCESS_MODE_DISABLED
	_hook_transform.remote_path = _hook.get_path()
	
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
	if _state_machine.in_state(FishingState.WAITING):
		_state_machine.switch(FishingState.FISH_HOOKED)


func _on_fish_caught() -> void:
	_reel_inn()
	
	_hook.spawn_fish()
	
	#SFX
	_caught_sfx.play_one_shot()


func _on_fish_escaped() -> void:
	_escaped_sfx.play_one_shot()
	_reel_inn()


#region Public

func use_rod() -> void:
	if _state_machine.in_state(FishingState.IDLE):
		if _hook.hooked_fish != null:
			_collect_fish()
		else:
			_ready_rod()

func stop_use_rod() -> void:
	if _state_machine.in_state(FishingState.READY_THROW):
		_throw_hook()


func reel_inn() -> void:
	if not _state_machine.in_state(FishingState.IDLE):
		_reel_inn()

func stop_reel_inn() -> void:
	pass

#endregion



func _enter_idle() -> void:
	await get_tree().create_timer(0.25).timeout
	_reset_rod()


func _enter_waiting() -> void:
	_throw_pos = global_position
	
	_hook_transform.remote_path = ""
	# Disconnect hook from pin
	_hook.scale = Vector3.ONE
	_hook.process_mode = Node.PROCESS_MODE_INHERIT
	_hook.top_level = true
	_hook.linear_damp = 0.0
	_hook.hook_state = FishingHook.HookState.THROWN
	
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


func _enter_ready_throw() -> void:
	Globals.started_fishing.emit()


func _process_ready_throw(delta: float) -> void:
	if _throw_charge_time < 1.0:
		var charge_speed: float = _balance_vars.throw_charge_speed
		_throw_charge_time += delta * charge_speed
		
		var charge_curve: Curve = _balance_vars.throw_charge_curve
		_throw_charge = charge_curve.sample(_throw_charge_time)


func _process_waiting(_delta: float) -> void:
	var distance: float = _throw_pos.distance_squared_to(_hook.global_position)
	var distance_curve: float = _balance_vars.hook_distance_curve.sample(distance)
	_distance_label.text = str(int(distance_curve))
	if _hook_los_check.is_colliding():
		_reel_inn()


func _enter_fish_hooked() -> void:
	pass


func _process_fish_hooked(_delta: float) -> void:
	_player.update_look_position(_hook.global_position)
