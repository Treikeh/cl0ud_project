extends Control


signal closed


const BUT_ENTRY_SCENE: PackedScene = preload("uid://3gn1kqoo470b")
const SELL_ENTRY_SCENE: PackedScene = preload("uid://d4epumjlgldtn")

@export var _sell_list: VBoxContainer
@export var _buy_list: VBoxContainer
@export var _currency_label: Label
@export var _tab_container: TabContainer

@export var _upgrades: Array[Upgrade] = []

var _inventory: Inventory


func with_data(inventory: Inventory, buying: bool = true) -> Control:
	_inventory = inventory
	_tab_container.current_tab = 0 if buying else 1
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
	for i: int in _upgrades.size():
		var buy_entry: BuyEntry = BUT_ENTRY_SCENE.instantiate().with_data(_upgrades[i])
		_buy_list.add_child(buy_entry)
		buy_entry.pressed.connect(_on_upgrade_pressed)
		buy_entry.bought.connect(_on_upgrade_bought)


func _close() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	closed.emit()
	queue_free()


func _on_item_sold(sell_entry: SellEntry) -> void:
	_inventory.currency += sell_entry.value
	_currency_label.text = str(_inventory.currency) + "$"
	_inventory.remove_item(sell_entry.index)
	sell_entry.queue_free()


func _on_upgrade_pressed(buy_entry: BuyEntry) -> void:
	if buy_entry.can_buy(_inventory.currency):
		buy_entry.buy(_inventory.player)

func _on_upgrade_bought(cost: int) -> void:
	_inventory.currency -= cost
	_currency_label.text = str(_inventory.currency) + "$"


func _on_close_button_pressed() -> void:
	_close()
