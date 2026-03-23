extends PanelContainer
class_name InventorySlot


signal pressed(slot_index: int)


@export var _icon: TextureRect


func with_data(item_data: ItemData) -> Control:
	set_slot_data(item_data)
	return self


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		pressed.emit(get_index())


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
