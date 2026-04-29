extends PanelContainer


signal pressed(index: int, item_data: ItemData)


@export var _icon: TextureRect
@export var _label: Label

var item_data: ItemData


func with_data(_item_data: ItemData) -> Control:
	item_data = _item_data
	_icon.texture = item_data.icon
	_label.text = item_data.name
	return self


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		pressed.emit(get_index(), item_data)


func set_slot_data(_item_data: ItemData) -> void:
	# Set data if there's data in the slot
	if _item_data:
		item_data = _item_data
		_icon.texture = item_data.icon
	# Empty slot if there's no data
	else:
		item_data = null
		_icon.texture = null
