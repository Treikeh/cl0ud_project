extends PanelContainer
class_name ProfileWallSlot


signal picked_up_slot(data: ItemData)
signal recived_data(data: ItemData)


@export var _required_data: ItemData
@export var _icon: TextureRect

var item_data: ItemData
var _mouse_inside: bool = false


func _ready() -> void:
	mouse_entered.connect(func(): _mouse_inside = true)
	mouse_exited.connect(func(): _mouse_inside = false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and _mouse_inside:
		picked_up_slot.emit(item_data)
		item_data = null
		_icon.texture = null


func add_entry(entry: ProfileWallEntry) -> void:
	pass


func remove_entry(entry: ProfileWallEntry) -> void:
	pass


func set_slot_data(_item_data: ItemData) -> void:
	if not _item_data:
		return
	
	item_data = _item_data
	_icon.texture = item_data.icon
	if item_data == _required_data:
		recived_data.emit(item_data)
