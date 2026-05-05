extends Control


signal closed
signal fish_printed(item_data: ItemData)


const ITEM_ENTRY_SCENE: PackedScene = preload("uid://c7cu5bxtffalu")

@export var _fish_list: Container
@export var _print_button: Button
@export var _fish_spawn_marker: Marker3D
@export var _data_container: Container

@export_group("Output")
@export var _output_label: Label
@export var _prev_output_button: Button
@export var _next_output_button: Button

@export var _recipes: Array[ProfileRecipe] = []

var _inventory: Inventory
var _selected_entry: Control
var _current_output_index: int = 0
var _output_item: ItemData


func with_data(inventory: Inventory, recipes: Array[ProfileRecipe]) -> Control:
	_inventory = inventory
	_recipes = recipes
	return self


func _ready() -> void:
	_open()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		_close()


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_print_button.disabled = true
	_prev_output_button.disabled = true
	_next_output_button.disabled = true
	
	_populate_fish_list()


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _populate_fish_list() -> void:
	# Populate fish list
	for i: int in _inventory.items.size():
		var fish: ItemData = _inventory.items[i]
		if not fish:
			continue
		if not fish.fish_data:
			continue
		var item_entry: Control = ITEM_ENTRY_SCENE.instantiate().with_data(fish, i)
		_fish_list.add_child(item_entry)
		item_entry.pressed.connect(_on_entry_pressed)


func _on_entry_pressed(entry: Control) -> void:
	_selected_entry = entry
	
	var item_data: ItemData = entry.item_data
	_update_mesh_dispaly(item_data)
	_update_data_container(item_data.fish_data)
	_current_output_index = 0
	_update_output(item_data)


func _update_mesh_dispaly(fish: ItemData) -> void:
	# Remove old mesh
	for node: Node in _fish_spawn_marker.get_children():
		_fish_spawn_marker.remove_child(node)
		node.queue_free()
	# Add new mesh
	var mesh: Node3D = load(fish.mesh_scene).instantiate()
	_fish_spawn_marker.add_child(mesh)


func _update_data_container(fish_data: FishData) -> void:
	# Remove old data
	for node: Node in _data_container.get_children():
		_data_container.remove_child(node)
		node.queue_free()
	# Add new data
	var display_scene: String = fish_data.get_display_scene()
	var display_menu: FishDataDisplay = load(display_scene).instantiate().with_data(fish_data)
	_data_container.add_child(display_menu)


func _update_output(item: ItemData) -> void:
	var outputs: Array[ItemData] = _get_recipie_outputs(item)
	if outputs.is_empty():
		return
	
	_print_button.disabled = false
	_prev_output_button.disabled = false
	_next_output_button.disabled = false
	_output_item = outputs[_current_output_index]
	_output_item.value = item.value
	_output_label.text = _output_item.name


func _get_recipie_outputs(fish: ItemData) -> Array[ItemData]:
	var outputs: Array[ItemData] = []
	for recipie: ProfileRecipe in _recipes:
		if recipie.input == fish:
			outputs = recipie.outputs
	return outputs


func _print_fish() -> void:
	if _selected_entry and _output_item:
		#TODO: Get the item with the recipe
		fish_printed.emit(_output_item)
		_inventory.remove_item(_selected_entry.index)
		_close()


func _on_prev_output_item_pressed() -> void:
	var item: ItemData = _selected_entry.item_data
	var desired_output: int = _current_output_index - 1
	if desired_output < 0:
		_current_output_index = _get_recipie_outputs(item).size() - 1
	else:
		_current_output_index = desired_output
	
	_update_output(item)


func _on_next_output_item_pressed() -> void:
	var item: ItemData = _selected_entry.item_data
	var desired_output: int = _current_output_index + 1
	if desired_output > _get_recipie_outputs(item).size() - 1:
		_current_output_index = 0
	else:
		_current_output_index = desired_output
	
	_update_output(item)
