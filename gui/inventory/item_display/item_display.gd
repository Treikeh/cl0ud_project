extends Control


@export var _name_label: Label
@export var _value_label: Label
@export var _type_label: Label
@export var _read_data_button: Button
@export var _fish_data_dispaly_root: Control

var _item_data: ItemData


func with_data(item_data: ItemData) -> Control:
	_item_data = item_data
	return self


func _ready() -> void:
	_name_label.text = "Name: %s" % _item_data.name
	_value_label.text = "Value: %s" % _item_data.value
	_type_label.text = "Type: %s" % _item_data.type
	
	_read_data_button.pressed.connect(_on_read_data_button_pressed)
	if _item_data.fish_data == null:
		_read_data_button.hide()


func _on_read_data_button_pressed() -> void:
	# Don't spawn more than 1 fish data display
	if _fish_data_dispaly_root.get_child_count() > 0:
		return
	
	# Make sure the path is valid before spawning the display
	var display_scene_path: String = _item_data.display_scene
	if display_scene_path == "":
		return
	
	var display_scene: Resource = load(display_scene_path)
	var display: FishDataDisplay = display_scene.instantiate().with_data(_item_data.fish_data)
	_fish_data_dispaly_root.add_child(display)
