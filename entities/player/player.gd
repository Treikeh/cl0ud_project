extends RigidBody3D
class_name Player


const GRAVITY_DIR: Vector3 = Vector3.DOWN

@export_group("Input")
@export var _orientation: Node3D
@export var _head: Node3D
@export var _interact_ray: RayCast3D

var _camera_sens: float = 0.1
var _move_input: Vector2

@export_group("Movement")
@export var _move_speed: float = 6.0
@export var _ground_accel: float = 500.0
@export var _air_accel: float = 200.0
@export var _jump_force: float = 5.0
@export var _ground_check: ShapeCast3D

var _is_jumping: bool = false
var _move_dir: Vector3


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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
	
	_move_input = Input.get_vector("move_l", "move_r", "move_f", "move_b")
	_move_dir = _orientation.global_basis * Vector3(_move_input.x, 0.0, _move_input.y).normalized()


func _physics_process(delta: float) -> void:
	if _ground_check.is_on_walkable_slope():
		_walking_physics(delta)
	else:
		_falling_physics(delta)


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
	
	#var gravity_vector: Vector3 = gravity_direction * gravity_force
	var gravity_vector: Vector3 = linear_velocity.dot(GRAVITY_DIR) * GRAVITY_DIR
	var needed_vel: Vector3 = target_vel - (linear_velocity - gravity_vector)
	apply_central_force(needed_vel * _air_accel * delta * mass)


func _jump() -> void:
	set_axis_velocity(-GRAVITY_DIR * _jump_force)
