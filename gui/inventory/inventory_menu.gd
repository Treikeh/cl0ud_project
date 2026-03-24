extends Control


signal closed


const SLOT_SCENE: PackedScene = preload("uid://cs35qk6fai74g")

@export var _slot_grid: GridContainer
@export var _select_marker: ColorRect
@export var _currency_label: Label
@export var _mesh_marker: Marker3D

var _inventory: Inventory


func with_data(inventory: Inventory) -> Control:
	_inventory = inventory
	return self


func _ready() -> void:
	_open()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_close()


func _process(delta: float) -> void:
	_mesh_marker.rotate_object_local(Vector3.UP, deg_to_rad(30.0 * delta))


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_select_marker.hide()
	_remove_preview_mesh()
	_populate_slot_grid()
	
	_currency_label.text = str(_inventory.currency) + "$"


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _populate_slot_grid() -> void:
	# Remove all the outdated slots (All the slots in this case)
	for child: Node in _slot_grid.get_children():
		_slot_grid.remove_child(child)
		child.queue_free()
	
	# Add all the updated slots (All the slots in this case)
	for item_data: ItemData in _inventory.items:
		var slot: InventorySlot = SLOT_SCENE.instantiate().with_data(item_data)
		_slot_grid.add_child(slot)
		slot.pressed.connect(_on_slot_pressed)


func _on_slot_pressed(slot_index: int) -> void:
	# Remove the old mesh preview
	_remove_preview_mesh()
	
	# Get the new pressed slot
	var pressed_slot: InventorySlot = _slot_grid.get_child(slot_index)
	# Move the select marker to the pressed slot
	_select_marker.global_position = pressed_slot.global_position
	
	# Show new mesh preview
	var item_data: ItemData = _inventory.get_slot_data(slot_index)
	if item_data:
		_show_preview_mesh(item_data)


func _show_preview_mesh(item_data: ItemData) -> void:
	var mesh: Node3D = load(item_data.mesh_scene).instantiate()
	_mesh_marker.add_child(mesh)
	# Reset mesh marker rotation
	_mesh_marker.rotation_degrees.y = 0.0


func _remove_preview_mesh() -> void:
	# Remove the old mesh preview
	for child: Node in _mesh_marker.get_children():
		_mesh_marker.remove_child(child)
		child.queue_free()
