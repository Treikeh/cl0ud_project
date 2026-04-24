extends Control


@export var _panel: PanelContainer


func _ready() -> void:
	_panel.hide()


func _input(event: InputEvent) -> void:
	if Globals.in_editor and event.is_action_pressed("debug"):
		if _panel.visible:
			close()
		else:
			open()


func open() -> void:
	get_tree().paused = true
	_panel.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	_setup_time_of_day()
	_setup_minutes_in_day()
	_setup_throw_upgrade()
	_setup_calm_upgrade()


func close() -> void:
	get_tree().paused = false
	_panel.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#region Time of day

func _setup_time_of_day() -> void:
	var day_night_cycle: DayNightCycle = get_tree().get_first_node_in_group("day_night_cycle")
	if day_night_cycle:
		%TimeOfDaySlider.value = day_night_cycle.get_time_of_day()
		%TimeOfDaySpinBox.value = day_night_cycle.get_time_of_day()
	else:
		%TimeOfDaySlider.editable = false
		%TimeOfDaySpinBox.editable = false


func _on_time_of_day_value_changed(value: float) -> void:
	var day_night_cycle: DayNightCycle = get_tree().get_first_node_in_group("day_night_cycle")
	day_night_cycle.set_time_of_day(value)
	
	%TimeOfDaySlider.value = value
	%TimeOfDaySpinBox.value = value

#endregion


#region Time of day

func _setup_minutes_in_day() -> void:
	var day_night_cycle: DayNightCycle = get_tree().get_first_node_in_group("day_night_cycle")
	if day_night_cycle:
		%MinutesInDaySlider.value = day_night_cycle._minutes_in_day
		%MinutesInDaySpinBox.value = day_night_cycle._minutes_in_day
	else:
		%MinutesInDaySlider.editable = false
		%MinutesInDaySpinBox.editable = false


func _on_minutes_in_day_value_changed(value: float) -> void:
	var day_night_cycle: DayNightCycle = get_tree().get_first_node_in_group("day_night_cycle")
	day_night_cycle._minutes_in_day = value
	
	%MinutesInDaySlider.value = value
	%MinutesInDaySpinBox.value = value

#endregion


#region Throw upgrade

func _setup_throw_upgrade() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		%ThrowUpgradeSlider.value = int(player.throw_upgrade_level)
		%ThrowUpgradeSpinBox.value = int(player.throw_upgrade_level)
	else:
		%ThrowUpgradeSlider.editable = false
		%ThrowUpgradeSpinBox.editable = false


func _on_throw_upgrade_value_changed(value: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	player.throw_upgrade_level = int(value)
	
	%ThrowUpgradeSlider.value = value
	%ThrowUpgradeSpinBox.value = value

#endregion

func _setup_calm_upgrade() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		%CalmUpgradeSlider.value = int(player.calm_fish_upgrade_level)
		%CalmUpgradeSpinBox.value = int(player.calm_fish_upgrade_level)
	else:
		%CalmUpgradeSlider.editable = false
		%CalmUpgradeSpinBox.editable = false


func _on_calm_upgrade_value_changed(value: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	player.calm_fish_upgrade_level = int(value)
	
	%CalmUpgradeSlider.value = value
	%CalmUpgradeSpinBox.value = value


#region Calm upgrade
