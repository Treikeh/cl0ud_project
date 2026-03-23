extends Control


const SLOT_SCENE: PackedScene = preload("uid://cs35qk6fai74g")

@export var _slot_grid: GridContainer
@export var _mesh_marker: Marker3D
@export var _select_marker: ColorRect

var _inventory: Inventory


func _ready() -> void:
	_select_marker.hide()


func _process(delta: float) -> void:
	_mesh_marker.rotate_object_local(Vector3.UP, deg_to_rad(30.0 * delta))


func setup(inventory: Inventory) -> void:
	_inventory = inventory
	_inventory.updated.connect(_populate_slot_grid)


func open() -> void:
	show()
	_populate_slot_grid()
	_remove_preview_mesh()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func close() -> void:
	hide()
	_select_marker.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _populate_slot_grid() -> void:
	# Remove all slots
	for child: Node in _slot_grid.get_children():
		_slot_grid.remove_child(child)
		child.queue_free()
	
	# Add all the slots
	for item_data: ItemData in _inventory.items:
		var slot: InventorySlot = SLOT_SCENE.instantiate().with_data(item_data)
		_slot_grid.add_child(slot)
		slot.pressed.connect(_on_slot_pressed)


func _on_slot_pressed(slot_index: int) -> void:
	# Remove the old mesh preview
	_remove_preview_mesh()
	
	var pressed_slot: InventorySlot = _slot_grid.get_child(slot_index)
	_select_marker.global_position = pressed_slot.global_position
	
	# Show new mesh preview
	var item_data: ItemData = _inventory.get_slot_data(slot_index)
	if item_data:
		_show_preview_mesh(item_data)


func _show_preview_mesh(item_data: ItemData) -> void:
	var mesh: Node3D = load(item_data.mesh_scene).instantiate()
	_mesh_marker.add_child(mesh)
	_mesh_marker.rotation_degrees.y = 0.0


func _remove_preview_mesh() -> void:
	# Remove the old mesh preview
	for child: Node in _mesh_marker.get_children():
		_mesh_marker.remove_child(child)
		child.queue_free()
