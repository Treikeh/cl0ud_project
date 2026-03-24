extends Node3D
class_name PlayerMovement

# Movement states the player can be in
enum {WALKING, FALLING, JUMPING}

const GRAVITY_DIR: Vector3 = Vector3.DOWN

@export var _move_speed: float = 6.0
@export var _ground_accel: float = 500.0
@export var _air_accel: float = 200.0
@export var _jump_force: float = 5.0

var _enabled: bool = true
var _is_jumping: bool = false
var _move_dir: Vector3

@onready var _player: Player = get_owner()
@onready var _ground_check: ShapeCast3D = get_child(0)
@onready var _state_machine := StateMachine.new({
	WALKING: {StateMachine.PHYSICS: _walking_physics},
	FALLING: {StateMachine.PHYSICS: _falling_physics},
	JUMPING: {StateMachine.ENTER: _jumping},
})


func _ready() -> void:
	_player.movement = self
	_ground_check.setup(_player, GRAVITY_DIR)
	
	# Init first state
	_state_machine.switch(FALLING)


func _physics_process(delta: float) -> void:
	if not _enabled:
		return
	
	_state_machine.physics(delta)


func _walking_physics(delta: float) -> void:
	_player.gravity_scale = 0.0
	# Give ground_check a buffer to improve the snapping when walking down ledges
	_ground_check.target_position.y = -1.0
	
	if _is_jumping:
		_state_machine.switch(JUMPING)
		return
	
	if not _ground_check.is_grounded():
		_state_machine.switch(FALLING)
		return
	
	var target_vel: Vector3 = _move_dir * _move_speed
	var needed_vel: Vector3 = target_vel - _player.linear_velocity
	_player.apply_central_force(needed_vel * _ground_accel * delta)
	_ground_check.snap_to_ground()
	#_camera.apply_head_bobbing(linear_velocity, delta)


func _falling_physics(delta: float) -> void:
	_player.gravity_scale = 1.0
	_ground_check.target_position.y = -0.6
	
	if _ground_check.is_grounded():
		_state_machine.switch(WALKING)
		return
	
	var target_vel: Vector3 = _move_dir * _move_speed
	var slope_normal: Vector3 = Vector3.ZERO
	
	#Bad fix for sliding up steep slopes while in the air
	if _move_dir and _ground_check.is_colliding():
		slope_normal = _ground_check.ground_normal
		slope_normal = Vector3(slope_normal.x, 0.0, slope_normal.z)
		target_vel = (_move_dir + slope_normal) * _move_speed
	
	var gravity_vector: Vector3 = _player.linear_velocity.dot(GRAVITY_DIR) * GRAVITY_DIR
	var needed_vel: Vector3 = target_vel - (_player.linear_velocity - gravity_vector)
	_player.apply_central_force(needed_vel * _air_accel * delta)


func _jumping() -> void:
	_player.set_axis_velocity(-GRAVITY_DIR * _jump_force)
	_state_machine.switch(FALLING)


#region Public

func set_enabled(enable: bool) -> void:
	_enabled = enable

func is_enabled() -> bool:
	return _enabled


func update_move_dir(move_dir: Vector3) -> void:
	_move_dir = move_dir

func update_jumping(is_jumping: bool) -> void:
	_is_jumping = is_jumping

#endregion
