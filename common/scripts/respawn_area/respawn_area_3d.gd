extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.global_position = body._respawn_point
		body.linear_velocity = Vector3.ZERO
