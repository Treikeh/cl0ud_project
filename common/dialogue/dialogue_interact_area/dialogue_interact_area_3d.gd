extends InteractArea3D


@export var _head_marker: Node3D
@export var _dialogue: Array[DialogueData] = []


func _ready() -> void:
	interacted.connect(_on_interacted)


func _on_interacted(player: Player) -> void:
	player.hud.start_dialogue(_dialogue)
	if _head_marker:
		player.update_look_position(_head_marker.global_position)
