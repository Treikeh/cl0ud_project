extends Control


signal closed


const ITEM_ENTRY_SCENE: PackedScene = preload("uid://c7cu5bxtffalu")

@export var _pieces_list: Container
@export var _selected_item_rect: TextureRect
@export var _profile: Control

var _piece_inventory: Inventory
var _selected_item: ItemData
var _selected_slot: Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()
	
	if event is InputEventMouseButton and event.is_released():
		if _selected_slot:
			_selected_slot.set_slot_data(_selected_item)
		_selected_item = null


func _process(_delta: float) -> void:
	var offset: Vector2 = _selected_item_rect.size / 2.0
	_selected_item_rect.global_position = get_global_mouse_position() - offset
	_selected_item_rect.texture = _selected_item.icon if _selected_item else null


func with_data(piece_inventory: Inventory) -> Control:
	_piece_inventory = piece_inventory
	return self


func _ready() -> void:
	for item: ItemData in _piece_inventory.items:
		if not item:
			continue
		var item_entry: Control = ITEM_ENTRY_SCENE.instantiate().with_data(item)
		_pieces_list.add_child(item_entry)
		item_entry.pressed.connect(_on_entry_pressed)
	_open()


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _on_entry_pressed(_index: int, item_data: ItemData) -> void:
	_selected_item = item_data


func _on_mouse_entered_slot(slot: Control) -> void:
	_selected_slot = slot


func _on_mouse_exited_slot() -> void:
	_selected_slot = null


func _on_slot_recived_data(data: NoteData, source: Control) -> void:
	var data_types: Dictionary[Label, Control] = _profile.data_types
	if data_types.values().has(source):
		var label_index: int = data_types.values().find(source)
		var label: Label = data_types.keys()[label_index]
		label.text += data.text
