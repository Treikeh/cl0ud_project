extends Node3D


@export var _default_look_point: Node3D
@export var _look_at_target: Marker3D
@export var _head_marker: Marker3D
@export var _interact_dialogue: Array[DialogueData] = []

var _player: Player


func _process(delta: float) -> void:
	var look_position: Vector3 = _default_look_point.global_position
	if _player:
		var dir: Vector3 = global_position.direction_to(_player.global_position)
		var dot: float = -global_basis.z.dot(dir)
		if dot > 0.2:
			look_position = _player._head.global_position
	
	_look_at_target.global_position = lerp(_look_at_target.global_position, look_position, delta * 5.0)


func _on_player_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		_player = body


func _on_player_trigger_body_exited(body: Node3D) -> void:
	if body == _player:
		_player = null


func _on_interact_area_3d_interacted(player: Player) -> void:
	# Start dialogue when interacting with the vendor
	player.update_look_position(_head_marker.global_position)
	var dialogue: Control = player.hud.start_dialogue(_interact_dialogue)
