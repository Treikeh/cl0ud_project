extends PanelContainer


signal slot_selected(slot: Control)
signal slot_grabbed(item_data: ItemData)


const PROFILE_WALL_SLOT_SCENE: PackedScene = preload("uid://daynk558nxhes")

@export var _profile_data: ProfileData

@onready var name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var age_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/AgeLabel
@onready var job_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/JobLabel


func _ready() -> void:
	_set_up_slot(name_label, ProfileData.DataTypes.NAME)


func _set_up_slot(label: Label, data_type: ProfileData.DataTypes) -> void:
	if _profile_data.data.has(data_type):
		# Spawn a slot for the data type
		var slot: ProfileWallSlot = PROFILE_WALL_SLOT_SCENE.instantiate()
		$Control/Control.add_child(slot)
		
		slot.data_added.connect(_on_data_added)
		
		slot.grabbed.connect(_on_slot_grabbed)
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot))
		slot.mouse_exited.connect(_on_slot_mouse_exited)
	else:
		label.visible = false


func _on_data_added(item_data: ItemData) -> void:
	print("Added data: %s" % item_data.name)


func _on_slot_grabbed(item_data: ItemData) -> void: slot_grabbed.emit(item_data)
func _on_slot_mouse_entered(source: Control) -> void: slot_selected.emit(source)
func _on_slot_mouse_exited() -> void: slot_selected.emit(null)
