extends ShapeCast3D


@export var _max_slope_angle: float = 46.0
## How much upwards force is needed before no longer counting as grounded
@export var _leave_floor_force: float = 5.0
## How far off the ground to move the player
@export var _rest_height: float = 1.0
@export var _spring_force: float = 300.0
@export var _spring_damping: float = 25.0

var ground_normal: Vector3 = Vector3.UP

var _gravity_dir: Vector3
var _player: Player


func setup(player: Player, gravity_dir: Vector3) -> void:
	_player = player
	_gravity_dir = gravity_dir


func is_grounded() -> bool:
	# Leave the ground if too much upwards force is applied
	if _player.linear_velocity.y >= _leave_floor_force:
		return false
	
	if is_colliding():
		ground_normal = get_collision_normal(0)
		# Compare ground normal to upwards direction to get the slope angle
		if ground_normal.angle_to(Vector3.UP) < deg_to_rad(_max_slope_angle):
			return true
		return false
	return false


# Apply a spring force that moves the palyer towards "rest_height"
func snap_to_ground() -> void:
	var hit_distance: float = (global_position - get_collision_point(0)).length()
	var normal_vel: float = -ground_normal.dot(_player.linear_velocity)
	var dispalcement: float = hit_distance - _rest_height
	var force: float = (_spring_force * dispalcement) - (normal_vel * _spring_damping)
	_player.apply_central_force(_gravity_dir * force)
