extends Character


@export var _trigger_dialogue: DialogueData
@export var _head_marker: Marker3D

var _has_spoken: bool = false


func _body_entered_trigger(body: Node3D) -> void:
	if body is Player and not _has_spoken:
		body.hud.start_dialogue(_trigger_dialogue)
		body.update_look_position(_head_marker.global_position)
		_has_spoken = true
