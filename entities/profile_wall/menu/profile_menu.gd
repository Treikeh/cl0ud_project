extends Control


signal closed


const ITEM_ENTRY_SCENE: PackedScene = preload("uid://bnw0d42wub0nx")

@export var _pieces_list: Container
@export var _selected_item_rect: TextureRect
@export var _profile: Control

var _inside_fish_list: bool = false
var _piece_inventory: Inventory
var _selected_entry: Control
var _selected_slot: Control
var _selected_item: ItemData

var _grabbed_entry: ProfileWallEntry


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()
	
	if event is InputEventMouseButton and event.is_released():
		print("ASDASD")
		if _selected_slot:
			print("PLÅPLÅPL")
			_grabbed_entry.target_position = _selected_slot.global_position
		_on_entry_dropped(_grabbed_entry)


func _process(_delta: float) -> void:
	var offset: Vector2 = _selected_item_rect.size / 2.0
	_selected_item_rect.global_position = get_global_mouse_position() - offset
	_selected_item_rect.texture = _selected_item.icon if _selected_item else null
	
	if _grabbed_entry:
		offset = _grabbed_entry.size / 2.0
		_grabbed_entry.global_position = get_global_mouse_position() - offset


func with_data(piece_inventory: Inventory) -> Control:
	_piece_inventory = piece_inventory
	return self


func _ready() -> void:
	_open()


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	_populate_item_list()


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _populate_item_list() -> void:
	for i: int in _piece_inventory.items.size():
		var item: ItemData = _piece_inventory.items[i]
		if not item:
			continue
		
		var label := Label.new()
		label.text = "\n \n"
		_pieces_list.add_child(label)
		
		await get_tree().process_frame
		
		var item_entry: ProfileWallEntry = ITEM_ENTRY_SCENE.instantiate().with_data(item)
		add_child(item_entry)
		item_entry.grabbed.connect(_on_entry_grabbed)
		item_entry.target_position = label.global_position
		item_entry.global_position = label.global_position


func _on_entry_grabbed(entry: ProfileWallEntry) -> void:
	entry.is_grabbed = true
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grabbed_entry = entry


func _on_entry_dropped(entry: ProfileWallEntry) -> void:
	entry.is_grabbed = false
	entry.mouse_filter = Control.MOUSE_FILTER_STOP
	_grabbed_entry = null


func _pick_up_entry(entry: Control) -> void:
	# Get saved entry
	_selected_entry = entry
	_selected_item = entry.item_data


func _on_slot_picked_up(item_data: ItemData) -> void:
	if item_data:
		_selected_item = item_data


func _drop_entry() -> void:
	if _selected_slot and _selected_item:
		_selected_entry.queue_free()
		_selected_slot.set_slot_data(_selected_item)
	_selected_item = null


func _on_mouse_entered_slot(slot: Control) -> void:
	_selected_slot = slot


func _on_mouse_exited_slot() -> void:
	_selected_slot = null


func _on_slot_recived_data(data: ItemData, source: Control) -> void:
	var data_types: Dictionary[Label, Control] = _profile.data_types
	if data_types.values().has(source):
		var label_index: int = data_types.values().find(source)
		var label: Label = data_types.keys()[label_index]
		label.text += data.description
