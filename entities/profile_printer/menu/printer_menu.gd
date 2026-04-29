extends Control


signal closed
signal fish_printed(item_data: ItemData)


const ITEM_ENTRY_SCENE: PackedScene = preload("uid://c7cu5bxtffalu")

@export var _fish_list: Container
@export var _print_button: Button
@export var _fish_spawn_marker: Marker3D
@export var _data_container: Container

var _inventory: Inventory
var _selected_index: int
var _selected_fish: ItemData


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()


func with_data(inventory: Inventory) -> Control:
	_inventory = inventory
	return self


func _ready() -> void:
	_print_button.disabled = true
	_open()


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Add fish to the fish list
	for fish: ItemData in _inventory.items:
		if not fish:
			continue
		var item_entry: Control = ITEM_ENTRY_SCENE.instantiate().with_data(fish)
		_fish_list.add_child(item_entry)
		item_entry.pressed.connect(_on_entry_pressed)


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _on_entry_pressed(index: int, item_data: ItemData) -> void:
	_selected_index = index
	_selected_fish = item_data
	_print_button.disabled = false
	
	for node: Node in _fish_spawn_marker.get_children():
		_fish_spawn_marker.remove_child(node)
		node.queue_free()
	
	var mesh: Node3D = load(_selected_fish.mesh_scene).instantiate()
	_fish_spawn_marker.add_child(mesh)
	
	var display_scene: String = _selected_fish.fish_data.get_display_scene()
	var display_menu: FishDataDisplay = load(display_scene).instantiate().with_data(_selected_fish.fish_data)
	_data_container.add_child(display_menu)


func _print_fish() -> void:
	if _selected_fish:
		fish_printed.emit(_selected_fish)
		_inventory.remove_item(_selected_index)
		_close()
