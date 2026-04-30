extends PanelContainer
class_name ProfileWallEntry


signal grabbed(entry: ProfileWallEntry)
#signal dropped(entry: ProfileWallEntry)


@export var _icon: TextureRect
@export var _name_label: Label

var item_data: ItemData
var is_grabbed: bool = false
var target_position := Vector2.ZERO

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
	if event is InputEventMouseButton and event.is_pressed() and _mouse_inside:
		grabbed.emit(self)


func _process(delta: float) -> void:
	if target_position and not is_grabbed:
		global_position = lerp(global_position, target_position, delta)
