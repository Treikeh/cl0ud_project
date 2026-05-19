extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.input.set_enabled(false)
		LevelManager.load_level("uid://cyxs8ixd0p0p3")
