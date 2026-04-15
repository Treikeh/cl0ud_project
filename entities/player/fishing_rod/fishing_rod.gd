extends Node3D
class_name FishingRod


enum FishingState {
	IDLE,
	READY_THROW,
	WAITING,
	FISH_HOOKED,
	REEL_IN,
}


@export var throw_force: float = 10.0
@export var _rod_mesh: Node3D
@export var _hook: FishingHook
@export var _pin_joint: PinJoint3D
@export var _pin_anchor: StaticBody3D
@export var _fishing_line: MeshInstance3D
@export var _fishing_line_mat: Material
@export var _throw_charge_curve: Curve

@export_group("SFX")
@export var _cast_sfx: FmodEventEmitter3D
@export var _reel_sfx: FmodEventEmitter3D
@export var _caught_sfx: FmodEventEmitter3D
@export var _escaped_sfx: FmodEventEmitter3D

var _throw_charge: float = 0.0
var _throw_charge_time: float = 0.0
var _throw_pos: Vector3
var _fish_timer: Timer
var _fishing_state: FishingState = FishingState.IDLE

@onready var _player: Player = get_owner()
@onready var _line_mesh: ImmediateMesh = _fishing_line.mesh


func _ready() -> void:
	_player.fishing_rod = self
	
	_hook.hook_hit_water.connect(_on_hook_hit_water)
	
	# Add timer for fishing
	_fish_timer = Timer.new()
	_fish_timer.wait_time = 3.0
	_fish_timer.one_shot = true
	_fish_timer.autostart = false
	add_child(_fish_timer)
	_fish_timer.timeout.connect(_on_fish_hooked)


func _process(delta: float) -> void:
	if _fishing_state == FishingState.READY_THROW and _throw_charge_time < 1.0:
		_throw_charge_time += delta * 2.0
		_throw_charge = _throw_charge_curve.sample(_throw_charge_time)
	
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
	_fishing_state = FishingState.WAITING
	_throw_pos = global_position
	
	# Disconnect hook from pin
	_pin_joint.node_b = _pin_anchor.get_path()
	_hook.top_level = true
	_hook.linear_damp = 0.0
	
	_fishing_state = FishingState.WAITING
	
	var force: Vector3 = -global_basis.z * (throw_force + _player.throw_force) + global_basis.y * 2.0
	_hook.set_axis_velocity(force * _throw_charge)
	_throw_charge_time = 0.0
	
	#SFX
	_cast_sfx.play_one_shot()


func _reset_rod() -> void:
	Globals.stopped_fishing.emit()
	_throw_charge = 0.0
	_fishing_state = FishingState.IDLE
	
	# Reset hook
	_hook.top_level = false
	_hook.linear_damp = 2.0
	_hook.gravity_scale = 1.0
	_hook.linear_velocity = Vector3.ZERO
	_hook.angular_velocity = Vector3.ZERO
	_hook.rotation_degrees = Vector3.ZERO
	
	# Reconnect hook to pin
	var hook_offset: Vector3 = -_pin_anchor.global_basis.y * 0.3
	_hook.global_position = _pin_anchor.global_position + hook_offset
	_pin_joint.node_b = _hook.get_path()
	
	#SFX
	_reel_sfx.play_one_shot()


func _collect_fish() -> void:
	Globals.fish_collected.emit(_hook.hooked_fish.item_data)
	_player.inventory.add_item(_hook.hooked_fish.item_data)
	_hook.hooked_fish.queue_free()


func _on_hook_hit_water() -> void:
	Globals.hook_distance = _throw_pos.distance_squared_to(_hook.global_position)
	_fish_timer.start()


func _on_fish_hooked() -> void:
	if _fishing_state == FishingState.WAITING:
		_fishing_state = FishingState.FISH_HOOKED
		Globals.fish_hooked.emit()


func fish_caught() -> void:
	_fishing_state = FishingState.REEL_IN
	
	_hook.spawn_fish()
	
	#SFX
	_caught_sfx.play_one_shot()


func fish_escaped() -> void:
	if _fishing_state == FishingState.FISH_HOOKED:
		_fishing_state = FishingState.WAITING
		_fish_timer.start()
		
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
		_reset_rod()

func stop_reel_inn() -> void:
	pass

#endregion
