extends Control


signal closed


const SLOT_SCENE: PackedScene = preload("uid://cs35qk6fai74g")
const ITEM_DISPALY_SCENE: PackedScene = preload("uid://cye3hnmivani4")

@export var _slot_grid: GridContainer
@export var _currency_label: Label
@export var _item_dispaly_root: Control
@export var _mesh_marker: Marker3D

@export_group("Item info")
@export var _name_label: RichTextLabel
@export var _type_label: RichTextLabel
@export var _value_label: RichTextLabel

@export_group("SFX")
@export var _open_sfx: FmodEventEmitter2D
@export var _close_sfx: FmodEventEmitter2D

var _inventory: Inventory
var _selected_slot: InventorySlot


func with_data(inventory: Inventory) -> Control:
	_inventory = inventory
	return self


func _ready() -> void:
	_open()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_close()
	
	if event.is_action_pressed("ui_cancel"):
		_close()


func _process(delta: float) -> void:
	_mesh_marker.rotate_object_local(Vector3.UP, deg_to_rad(30.0 * delta))


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_remove_preview_mesh()
	_populate_slot_grid()
	
	_currency_label.text = str(_inventory.currency) + "$"
	
	_open_sfx.play_one_shot()


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	_close_sfx.play_one_shot()
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
	_remove_item_display()
	if _selected_slot:
		_selected_slot.is_selected = false
	
	# Get the new pressed slot
	_selected_slot = _slot_grid.get_child(slot_index)
	
	# Show new mesh preview
	var item_data: ItemData = _inventory.get_slot_data(slot_index)
	if item_data:
		_show_preview_mesh(item_data)
		_show_item_dispaly(item_data)
		_selected_slot.is_selected = true
		_name_label.text = item_data.name
		_type_label.text = item_data.type
		_value_label.text = str(item_data.value)


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


func _show_item_dispaly(item_data: ItemData) -> void:
	if item_data.fish_data:
		var display_scene_path: String = item_data.fish_data.get_display_scene()
		var display_scene: Resource = load(display_scene_path)
		var display: FishDataDisplay = display_scene.instantiate().with_data(item_data.fish_data)
		_item_dispaly_root.add_child(display)
	#var display: Control = ITEM_DISPALY_SCENE.instantiate().with_data(item_data)
	#_item_dispaly_root.add_child(display)



func _remove_item_display() -> void:
	for child: Control in _item_dispaly_root.get_children():
		_item_dispaly_root.remove_child(child)
		child.queue_free()
