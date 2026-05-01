extends PanelContainer
class_name ProfileWallEntry


signal grabbed(item: ItemData)


@export var _icon: TextureRect
@export var _name_label: Label

var item_data: ItemData
var _mouse_inside: bool = false


func with_data(_item_data: ItemData) -> ProfileWallEntry:
	item_data = _item_data
	_icon.texture = item_data.icon
	_name_label.text = item_data.name
	return self


func _ready() -> void:
	mouse_entered.connect(func(): _mouse_inside = true)
	mouse_exited.connect(func(): _mouse_inside = false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("throw_hook") and _mouse_inside:
		grabbed.emit.call_deferred(item_data)
		queue_free()
