extends Control


const SELL_ENTRY_SCENE: PackedScene = preload("uid://d4epumjlgldtn")

@export var _sell_list: VBoxContainer

var _inventory: Inventory


func open(inventory: Inventory) -> void:
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	_inventory = inventory
	# Populate sell list
	for i: int in _inventory.items.size():
		var item_data: ItemData = _inventory.items[i]
		if item_data:
			var sell_entry: SellEntry = SELL_ENTRY_SCENE.instantiate().with_data(item_data, i)
			_sell_list.add_child(sell_entry)
			sell_entry.item_sold.connect(_on_item_sold)


func close() -> void:
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_inventory = null
	# Clear sell list when the menu is closed
	for child: Node in _sell_list.get_children():
		_sell_list.remove_child(child)
		child.queue_free()


func _on_item_sold(sell_entry: SellEntry) -> void:
	_inventory.remove_item(sell_entry.index)
	sell_entry.queue_free()


func _on_close_button_pressed() -> void:
	close()
