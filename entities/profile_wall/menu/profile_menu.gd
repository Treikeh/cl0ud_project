extends Control


signal closed


const ITEM_ENTRY_SCENE: PackedScene = preload("uid://bnw0d42wub0nx")

@export var _pieces_list: Container
@export var _profile: Control
@export var _selected_item_icon: TextureRect

var _inventory: Inventory
var _piece_inventory: Inventory
var _grabbed_item: ItemData
var _selected_slot: ProfileWallSlot


func with_data(inventory: Inventory, piece_inventory: Inventory) -> Control:
	_inventory = inventory
	_piece_inventory = piece_inventory
	return self


func _ready() -> void:
	_open()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		_close()
	
	if event.is_action_pressed("throw_hook"):
		if _grabbed_item:
			if _selected_slot:
				_selected_slot.add_item(_grabbed_item)
			else:
				_piece_inventory.add_item(_grabbed_item)
				_populate_item_list()
			_grabbed_item = null


func _process(_delta: float) -> void:
	# Move selected item icon to mouse cursor
	var mouse_pos: Vector2 = get_global_mouse_position()
	var offset: Vector2 = _selected_item_icon.size / 2.0
	_selected_item_icon.global_position = mouse_pos - offset
	_selected_item_icon.texture = _grabbed_item.icon if _grabbed_item else null


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_populate_item_list()


func _close() -> void:
	if _grabbed_item:
		_piece_inventory.add_item(_grabbed_item)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _populate_item_list() -> void:
	# Remove all old entries
	for child: Node in _pieces_list.get_children():
		_pieces_list.remove_child(child)
		child.queue_free()
	
	for i: int in _piece_inventory.items.size():
		var item: ItemData = _piece_inventory.items[i]
		# Check if item is valid
		if item:
			_add_item_entry(item)


func _add_item_entry(item: ItemData) -> void:
	var item_entry: ProfileWallEntry = ITEM_ENTRY_SCENE.instantiate().with_data(item)
	_pieces_list.add_child(item_entry)
	item_entry.grabbed.connect(_on_entry_grabbed)


func _on_entry_grabbed(item: ItemData) -> void:
	_grabbed_item = item
	_piece_inventory.remove_item(_piece_inventory.items.find(item))


func _on_item_grabbed(item: ItemData) -> void: _grabbed_item = item


func _on_slot_grabbed(item: ItemData) -> void: _grabbed_item = item
func _on_slot_selected(slot: Control) -> void: _selected_slot = slot


func _create_item_from_profile() -> ItemData:
	var item := ItemData.new()
	item.name = "Profile: %s" % _profile.name
	return item
