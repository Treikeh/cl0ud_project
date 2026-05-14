extends PanelContainer
class_name InventorySlot


signal pressed(slot_index: int)


@export var _icon: TextureRect
@export var _select_highlight: CanvasItem

var is_selected: bool = false


func with_data(item_data: ItemData) -> Control:
	set_slot_data(item_data)
	return self


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		pressed.emit(get_index())

func _process(delta: float) -> void:
	_select_highlight.visible = is_selected


func set_slot_data(item_data: ItemData) -> void:
	# Set data if there's data in the slot
	if item_data:
		_icon.texture = item_data.icon
	# Empty slot if there's no data
	else:
		_icon.texture = null


func select() -> void:
	pass


func unselect() -> void:
	pass
