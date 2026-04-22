extends Node3D
class_name Character


@export_group("Look at player")
@export var _look_at_radius: float = 3.0
@export var _default_look_position: Node3D

@export_group("Skinning")
@export_enum("Base", "Vendor", "Nils") var _skin: String = "Base"
@export var _animation: AnimationRootNode

@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _look_at_modifier: LookAtModifier3D = $Skeleton3D/LookAtModifier3D
@onready var _player_trigger_collision: CollisionShape3D = $PlayerLookAtTrigger/CollisionShape3D


func _ready() -> void:
	_animation_tree.tree_root = _animation
	_player_trigger_collision.shape.radius = _look_at_radius
	
	# Disable all skins expect for the selected one
	var skeleton: Skeleton3D = $Skeleton3D
	for i: int in skeleton.get_child_count():
		var child: Node = skeleton.get_child(i)
		if child is MeshInstance3D:
			child.visible = true if child.name == _skin else false

func _on_player_look_at_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		_look_at_modifier.target_node = body._head.get_path()


func _on_player_look_at_trigger_body_exited(body: Node3D) -> void:
	if body is Player:
		_look_at_modifier.target_node = _default_look_position.get_path()
