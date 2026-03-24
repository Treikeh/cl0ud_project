extends Node3D


func _on_fog_area_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.gravity_scale = 0.0
		body.linear_velocity = Vector3.ZERO
		if body.get_parent().has_method("_on_hook_hit_water"):
			body.get_parent()._on_hook_hit_water()
