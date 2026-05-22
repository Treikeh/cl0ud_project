extends Node3D


@export var _open_gate: Node3D
@export var _closed_gate: Node3D
@export var _required_item: ItemData


func _ready() -> void:
	_enable_node(_open_gate)
	_disable_node(_closed_gate)


func _enable_node(node: Node3D) -> void:
	node.show()
	node.process_mode = Node.PROCESS_MODE_INHERIT


func _disable_node(node: Node3D) -> void:
	node.hide()
	node.process_mode = Node.PROCESS_MODE_DISABLED


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		if body.inventory.items.has(_required_item):
			_enable_node(_open_gate)
			_disable_node(_closed_gate)
