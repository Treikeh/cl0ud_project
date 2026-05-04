extends PanelContainer
class_name ProfileWallSlot


signal grabbed(item: ItemData)
signal data_added(item: ItemData)


@export var _icon: TextureRect

var item_data: ItemData
var _mouse_inside: bool = false


func _ready() -> void:
	mouse_entered.connect(func(): _mouse_inside = true)
	mouse_exited.connect(func(): _mouse_inside = false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_hook") and _mouse_inside:
		grabbed.emit.call_deferred(item_data)
		remove_item()


func add_item(data: ItemData) -> void:
	# Swap item if theres allready an item there
	if item_data:
		var old_data: ItemData = item_data
		grabbed.emit.call_deferred(old_data)
	
	item_data = data
	_icon.texture = item_data.icon
	
	data_added.emit(data)


func remove_item() -> void:
	_icon.texture = null
	item_data = null
