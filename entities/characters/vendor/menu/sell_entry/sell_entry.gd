extends PanelContainer
class_name SellEntry


signal item_sold(sell_entry: SellEntry)


@export var _icon: TextureRect
@export var _name_label: Label
@export var _value_label: Label

var value: int = 0
var index: int = 0


func with_data(item_data: ItemData, item_index: int) -> SellEntry:
	_icon.texture = item_data.icon
	_name_label.text = item_data.name
	_value_label.text = str(item_data.value)
	value = item_data.value
	index = item_index
	return self


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_sell_item()


func _sell_item() -> void:
	item_sold.emit(self)
