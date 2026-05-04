extends PanelContainer


signal slot_selected(slot: Control)
signal slot_grabbed(item_data: ItemData)


const PROFILE_WALL_SLOT_SCENE: PackedScene = preload("uid://daynk558nxhes")

@export var _profile_data: ProfileData
@export var _spawn_points: Control
@export var _labels: Dictionary[ProfileData.DataTypes, Label]

var slots: Array[ProfileWallSlot] = []

@onready var output_item := ItemData.new({
		"name": "Profile",
		"value": 10,
		"type": "PROFILE",
		"icon": "res://icon.svg",
		"mesh_scene": "res://entities/fish/note/note_mesh.tscn",
		"fish_data": ""
	})


func _ready() -> void:
	# Set up all slots
	for i: int in _labels.size():
		var type: ProfileData.DataTypes = _labels.keys()[i]
		var label: Label = _labels.values()[i]
		if _profile_data.data.has(type):
			# Add a slot for the type
			var slot: ProfileWallSlot = PROFILE_WALL_SLOT_SCENE.instantiate()
			_spawn_points.get_child(i).add_child(slot)
			
			slot.data_added.connect(_on_data_added.bind(label, type))
			slot.data_removed.connect(_on_data_removed.bind(label, type))
		
			slot.grabbed.connect(_on_slot_grabbed)
			slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot))
			slot.mouse_exited.connect(_on_slot_mouse_exited)
			
			slots.append(slot)
		else:
			label.hide()


func _on_data_added(item_data: ItemData, label: Label, type: ProfileData.DataTypes) -> void:
	label.text += item_data.description
	_update_item(type, item_data.description)


func _on_data_removed(item_data: ItemData, label: Label, type: ProfileData.DataTypes) -> void:
	label.text = label.text.trim_suffix(item_data.description)
	_update_item(type, "")


func _update_item(data_type: ProfileData.DataTypes, data: String) -> void:
	match data_type:
		ProfileData.DataTypes.NAME:
			output_item.name = "%s's profile" % data


func _on_slot_grabbed(item_data: ItemData) -> void: slot_grabbed.emit(item_data)
func _on_slot_mouse_entered(source: Control) -> void: slot_selected.emit(source)
func _on_slot_mouse_exited() -> void: slot_selected.emit(null)
