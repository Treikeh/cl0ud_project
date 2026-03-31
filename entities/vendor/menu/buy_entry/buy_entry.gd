extends PanelContainer
class_name BuyEntry


signal item_bought(buy_entry: BuyEntry)


@export var _name_label: Label
@export var _value_label: Label

var item: ItemData


func with_data(item_data: ItemData) -> BuyEntry:
	item = item_data
	_name_label.text = item.name
	_value_label.text = str(item.value)
	return self


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_buy_item()


func _buy_item() -> void:
	item_bought.emit(self)
