extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.global_position = body._respawn_point
		body.linear_velocity = Vector3.ZERO
		# Stop minigame when respawning
		body._on_hook_reeled(true)
		var minigames: Control = get_tree().get_first_node_in_group("minigames")
		if minigames: minigames._on_minigames_failed()
