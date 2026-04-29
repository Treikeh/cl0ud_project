extends PanelContainer


signal recived_data(data: NoteData)


@export var _required_data: ItemData
@export var _icon: TextureRect


func set_slot_data(item_data: ItemData) -> void:
	if not item_data:
		return
	_icon.texture = item_data.icon
	if item_data.fish_data == _required_data.fish_data:
		recived_data.emit(item_data.fish_data)
