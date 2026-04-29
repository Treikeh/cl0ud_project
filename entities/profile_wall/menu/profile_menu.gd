extends Control


signal closed


const ITEM_ENTRY_SCENE: PackedScene = preload("uid://c7cu5bxtffalu")

@export var _pieces_list: Container

var _piece_inventory: Inventory
var _selected_piece: ItemData


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()


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
	_selected_piece = item_data
