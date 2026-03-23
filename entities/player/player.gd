extends RigidBody3D
class_name Player


const GRAVITY_DIR: Vector3 = Vector3.DOWN

@export_group("Input")
@export var _orientation: Node3D
@export var _head: Node3D
@export var _interact_ray: RayCast3D

var minigame_look_dir: Vector2

var _is_jumping: bool = false
var _camera_sens: float = 0.1
var _move_input: Vector2


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_setup_hud()
	
	# Add timer for fishing
	_fish_timer = Timer.new()
	_fish_timer.wait_time = 3.0
	_fish_timer.one_shot = true
	_fish_timer.autostart = false
	_fishing_rod.add_child(_fish_timer)
	_fish_timer.timeout.connect(_fish_hooked)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_orientation.rotate_object_local(Vector3.UP, -deg_to_rad(event.relative.x * _camera_sens))
		_head.rotate_object_local(Vector3.RIGHT, -deg_to_rad(event.relative.y * _camera_sens))
		_head.rotation.x = clampf(_head.rotation.x, deg_to_rad(-89.0), deg_to_rad(89))
	
	if event.is_action_pressed("jump"):
		_is_jumping = true
	elif event.is_action_released("jump"):
		_is_jumping = false
	
	if event.is_action_pressed("interact"):
		_interact_ray.try_interact()
	
	if event.is_action_pressed("throw_hook"):
		if _fishing_state == FishingState.IDLE:
			if _hooked_fish:
				_collect_fish()
			else:
				_ready_fishing_rod()
	if event.is_action_released("throw_hook"):
		if _fishing_state == FishingState.READY_THROW:
			_throw_hook()
	
	if event.is_action_pressed("reel_hook"):
		if _fishing_state != FishingState.IDLE:
			_reset_hook()
	
	_move_input = Input.get_vector("move_l", "move_r", "move_f", "move_b")
	_move_dir = _orientation.global_basis * Vector3(_move_input.x, 0.0, _move_input.y).normalized()


func _process(delta: float) -> void:
	if _fishing_state == FishingState.FISH_HOOKED:
		# Make the camera look at the hook
		var dir_to_hook: Vector3 = _head.global_position.direction_to(_hook.global_position)
		var _h_rot: float = atan2(-dir_to_hook.x, -dir_to_hook.z)
		_orientation.rotation.y = lerp_angle(_orientation.rotation.y, _h_rot - minigame_look_dir.x, 3.0 * delta)
		var _v_rot: float = atan2(dir_to_hook.y, -dir_to_hook.z)
		_head.rotation.x = lerp_angle(_head.rotation.x, _v_rot - minigame_look_dir.y, 3.0 * delta)
	
	_display_fishing_line()


func _physics_process(delta: float) -> void:
	if _ground_check.is_on_walkable_slope():
		_walking_physics(delta)
	else:
		_falling_physics(delta)
	
	if _fishing_state == FishingState.REEL_IN:
		var launch_dir: Vector3 = _hook.global_position.direction_to(global_position) + (Vector3.UP * 0.15)
		var launch_force: float = _hook.global_position.distance_to(global_position) * 0.75
		_hook.apply_central_force(launch_dir * launch_force)
		if _hook.global_position.distance_squared_to(_head.global_position) <= 25.0:
			_reset_hook()


#region Movement

@export_group("Movement")
@export var _move_speed: float = 6.0
@export var _ground_accel: float = 500.0
@export var _air_accel: float = 200.0
@export var _jump_force: float = 5.0
@export var _ground_check: ShapeCast3D

var _move_dir: Vector3


func _walking_physics(delta: float) -> void:
	gravity_scale = 0.0
	# Give ground_check a buffer to improve the snapping when walking down ledges
	_ground_check.target_position.y = -1.0
	
	if _is_jumping:
		_jump()
		return
	
	var target_vel: Vector3 = _move_dir * _move_speed
	var needed_vel: Vector3 = target_vel - linear_velocity
	apply_central_force(needed_vel * _ground_accel * delta * mass)
	_ground_check.snap_to_ground()
	#_camera.apply_head_bobbing(linear_velocity, delta)


func _falling_physics(delta: float) -> void:
	gravity_scale = 1.0
	_ground_check.target_position.y = -0.6
	
	var target_vel: Vector3 = _move_dir * _move_speed
	var slope_normal: Vector3 = Vector3.ZERO
	
	#Bad fix for sliding up steep slopes while in the air
	if _move_dir and _ground_check.is_colliding():
		slope_normal = _ground_check.ground_normal
		slope_normal = Vector3(slope_normal.x, 0.0, slope_normal.z)
		target_vel = (_move_dir + slope_normal) * _move_speed
	
	var gravity_vector: Vector3 = linear_velocity.dot(GRAVITY_DIR) * GRAVITY_DIR
	var needed_vel: Vector3 = target_vel - (linear_velocity - gravity_vector)
	apply_central_force(needed_vel * _air_accel * delta * mass)


func _jump() -> void:
	set_axis_velocity(-GRAVITY_DIR * _jump_force)

#endregion


#region Fishing


enum FishingState {
	IDLE,
	READY_THROW,
	WAITING,
	FISH_HOOKED,
	REEL_IN,
}


@export_group("Fishing")
@export var _fishing_rod: Node3D
@export var _hook: RigidBody3D
@export var _fishing_line: MeshInstance3D
@export var _fishing_line_makrer: Marker3D
@export var _fishing_line_mat: Material
@export var _pin_joint: PinJoint3D
@export var _pin_anchor: StaticBody3D

@onready var _line_mesh: ImmediateMesh = _fishing_line.mesh

var _fishing_state: FishingState = FishingState.IDLE
var _fish_timer: Timer
var _hooked_fish: Node3D


func _ready_fishing_rod() -> void:
	_fishing_state = FishingState.READY_THROW


func _throw_hook() -> void:
	_pin_joint.node_b = _pin_anchor.get_path()
	_hook.top_level = true
	_hook.linear_damp = 0.0
	
	_fish_timer.start()
	
	_fishing_state = FishingState.WAITING
	
	await get_tree().physics_frame
	_hook.global_position = _head.global_position
	_hook.apply_central_impulse(-_head.global_basis.z * 15.0)


func _reset_hook() -> void:
	_hook.top_level = false
	_hook.linear_velocity = Vector3.ZERO
	_hook.angular_velocity = Vector3.ZERO
	_hook.linear_damp = 2.0
	_hook.gravity_scale = 1.0
	
	_fishing_state = FishingState.IDLE
	
	_hook.rotation_degrees = Vector3.ZERO
	var hook_offset: Vector3 = -_fishing_line_makrer.global_basis.y * 0.3
	_hook.global_position = _fishing_line_makrer.global_position + hook_offset
	_pin_joint.node_b = _hook.get_path()


func _fish_hooked() -> void:
	if _fishing_state == FishingState.WAITING:
		_fishing_state = FishingState.FISH_HOOKED
		fish_hooked.emit()


func _display_fishing_line() -> void:
	_line_mesh.clear_surfaces()
	_line_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, _fishing_line_mat)
	# End point
	_line_mesh.surface_add_vertex(_hook.global_position + _hook.global_basis.x * 0.02)
	_line_mesh.surface_add_vertex(_hook.global_position - _hook.global_basis.x * 0.02)
	
	# Start point
	_line_mesh.surface_add_vertex(_fishing_line_makrer.global_position + global_basis.x * 0.02)
	_line_mesh.surface_add_vertex(_fishing_line_makrer.global_position - global_basis.x * 0.02)
	
	_line_mesh.surface_end()


func _on_minigames_succeeded()-> void:
	_fishing_state = FishingState.REEL_IN
	# Spawn a fish on the hook
	var test_fish_scene: PackedScene = load("res://entities/fish/test_fish/test_fish.tscn")
	_hooked_fish = test_fish_scene.instantiate()
	_hook.get_child(1).add_child(_hooked_fish)


func _on_minigames_failed() -> void:
	if _fishing_state == FishingState.FISH_HOOKED:
		_fishing_state = FishingState.WAITING
		_fish_timer.start()


func _collect_fish() -> void:
	_hooked_fish.queue_free()

#endregion


#region UI

signal fish_hooked


const HUD_SCENE: PackedScene = preload("res://gui/hud/hud.tscn")


func _setup_hud() -> void:
	var hud: Control = HUD_SCENE.instantiate().with_data(self)
	add_child(hud)
	
	hud.minigames_root.minigames_succeeded.connect(_on_minigames_succeeded)
	hud.minigames_root.minigames_failed.connect(_on_minigames_failed)


#endregion
