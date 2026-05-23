extends PanelContainer
class_name ProfileWallSlot


signal grabbed(item: ItemData)
signal data_added(item: ItemData)
signal data_removed(item: ItemData)


@export var _icon: TextureRect

var item_data: ItemData
var slot_type: ProfileData.DataTypes
var _mouse_inside: bool = false

@onready var _default_image: Texture2D = _icon.texture


func with_data(type: ProfileData.DataTypes) -> ProfileWallSlot:
	slot_type = type
	return self


func _ready() -> void:
	mouse_entered.connect(func():
			_mouse_inside = true
			create_tween().tween_property(self, "scale", Vector2.ONE * 1.2, 0.1)
	)
	mouse_exited.connect(func():
			_mouse_inside = false
			create_tween().tween_property(self, "scale", Vector2.ONE, 0.1)
	)


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
	if item_data:
		var data: ItemData = item_data
		data_removed.emit(data)
	_icon.texture = _default_image
	item_data = null
