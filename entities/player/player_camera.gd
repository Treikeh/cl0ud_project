extends Node3D
class_name PlayerCamera


@export var cam: Camera3D

@onready var _player: Player = get_owner();


func _ready() -> void:
	_player.camera = self


@export_group("Head bobbing")
@export var hb_frequency: float = 1.0
@export var hb_amplitude: float = 0.025
var hb_time: float = 0.0


func apply_head_bobbing(velocity: Vector3, delta: float) -> void:
	hb_time += delta * velocity.length()
	var horizontal: float = sin(hb_time * hb_frequency * 0.5) * hb_amplitude
	var vertical: float = sin(hb_time * hb_frequency) * hb_amplitude
	transform.origin = Vector3(horizontal, vertical, 0.0)

#endregion


#region Camera tilt

@export_group("Camera tilt")
@export var max_tilt: float = 3.0
@export var tilt_speed: float = 1.0


func apply_camera_tilt(velocity: Vector3, input: Vector3, delta: float) -> void:
	var dir_dot: float = 0.0
	if input:
		# Calculate how much the player is moving towards the right
		dir_dot = global_basis.x.dot(velocity.normalized())
	# Rotate camera z towards max_tilt multiplied by how much the player is moving towards the right
	rotation.z = lerp_angle(rotation.z, -deg_to_rad(max_tilt) * dir_dot, tilt_speed * delta)

#endregion
