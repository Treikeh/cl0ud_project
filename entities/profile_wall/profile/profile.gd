extends PanelContainer


signal slot_selected(slot: Control)
signal slot_grabbed(item_data: ItemData)


const PROFILE_WALL_SLOT_SCENE: PackedScene = preload("uid://daynk558nxhes")

@export var _spawn_points: Control
@export var _labels: Dictionary[ProfileData.DataTypes, Label]
@export var _profiles: Array[ProfileData]

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
		var slot: ProfileWallSlot = PROFILE_WALL_SLOT_SCENE.instantiate().with_data(type)
		_spawn_points.get_child(i).add_child(slot)
		
		slot.data_added.connect(_on_data_added.bind(label, type))
		slot.data_removed.connect(_on_data_removed.bind(label, type))
		
		slot.grabbed.connect(_on_slot_grabbed)
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot))
		slot.mouse_exited.connect(_on_slot_mouse_exited)
		
		slots.append(slot)


func _on_data_added(item_data: ItemData, label: Label, type: ProfileData.DataTypes) -> void:
	label.text += item_data.description
	_update_item(type, item_data.description)
	_set_output_value()


func _on_data_removed(item_data: ItemData, label: Label, type: ProfileData.DataTypes) -> void:
	label.text = label.text.trim_suffix(item_data.description)
	_update_item(type, "")
	_set_output_value()


func _update_item(data_type: ProfileData.DataTypes, data: String) -> void:
	match data_type:
		ProfileData.DataTypes.NAME:
			output_item.name = "%s's profile" % data


func _set_output_value() -> void:
	output_item.value = 10
	
	var profiles_added: Dictionary = {}
	for profile: ProfileData in _profiles:
		profiles_added[profile] = []
	
	for slot: ProfileWallSlot in slots:
		# Get and check if the item exits
		var item: ItemData = slot.item_data
		if not item:
			continue
		
		# Increase output value if the item is in the right slot
		var added_value: int = item.value
		var slot_type: ProfileData.DataTypes = slot.slot_type
		for profile: ProfileData in _profiles:
			# Check if the profile has the data type
			if not profile.data.has(slot_type):
				continue
			# Increase the value of the profile if the item is placed in the right slot
			if profile.data[slot_type] == item:
				added_value += 5
		
		# Check if item maches items from other profiles
		var profile_to_check: ProfileData
		for profile: ProfileData in _profiles:
			if profile.has_item(item):
				profile_to_check = profile
				#print("%s profile has item %s" % [profile.resource_path, item.name])
				if not profiles_added[profile].has(item):
					profiles_added[profile].append(item)
		
		if not profile_to_check:
			continue
		
		var match_value: int = 0
		for type: ProfileData.DataTypes in profile_to_check.data:
			var item_: ItemData = profile_to_check.data[type]
			if profiles_added[profile_to_check].has(item_):
				match_value += 5
		
		output_item.value += added_value + match_value
	print(output_item.value)


func is_empty() -> bool:
	for slot: ProfileWallSlot in slots:
		if slot.item_data:
			return false
	return true

func _on_slot_grabbed(item_data: ItemData) -> void: slot_grabbed.emit(item_data)
func _on_slot_mouse_entered(source: Control) -> void: slot_selected.emit(source)
func _on_slot_mouse_exited() -> void: slot_selected.emit(null)
