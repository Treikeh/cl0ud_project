extends Control


signal closed


const BUT_ENTRY_SCENE: PackedScene = preload("uid://3gn1kqoo470b")
const SELL_ENTRY_SCENE: PackedScene = preload("uid://d4epumjlgldtn")

@export var _sell_list: VBoxContainer
@export var _buy_list: VBoxContainer
@export var _currency_label: Label
@export var _buy_item: ItemData

var _inventory: Inventory


func with_data(inventory: Inventory) -> Control:
	_inventory = inventory
	return self


func _ready() -> void:
	_open()


func _open() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_currency_label.text = str(_inventory.currency) + "$"
	# Populate sell list
	for i: int in _inventory.items.size():
		var item_data: ItemData = _inventory.items[i]
		if item_data:
			var sell_entry: SellEntry = SELL_ENTRY_SCENE.instantiate().with_data(item_data, i)
			_sell_list.add_child(sell_entry)
			sell_entry.item_sold.connect(_on_item_sold)
	
	# Populate but list
	for i: int in range(0, 5):
		var buy_entry: BuyEntry = BUT_ENTRY_SCENE.instantiate().with_data(_buy_item)
		_buy_list.add_child(buy_entry)
		buy_entry.item_bought.connect(_on_item_bought)


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _on_item_sold(sell_entry: SellEntry) -> void:
	_inventory.currency += sell_entry.value
	_currency_label.text = str(_inventory.currency) + "$"
	_inventory.remove_item(sell_entry.index)
	sell_entry.queue_free()


func _on_item_bought(buy_entry: BuyEntry) -> void:
	if _inventory.currency >= buy_entry.item.value:
		_inventory.currency -= buy_entry.item.value
		_currency_label.text = str(_inventory.currency) + "$"
		#_inventory.add_item(buy_entry.item)
		buy_entry.queue_free()


func _on_close_button_pressed() -> void:
	_close()
