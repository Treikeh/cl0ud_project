@tool
extends EditorPlugin


var dock: EditorDock


func _enable_plugin() -> void:
	_create_settings_file()


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	var dock_scene = preload("res://addons/cl0ud_plugin/dock/dock.tscn").instantiate()
	
	dock = EditorDock.new()
	dock.add_child(dock_scene)
	
	dock.title = "CL0UD Stuff"
	dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	
	add_dock(dock)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_dock(dock)
	dock.queue_free()


func _create_settings_file() -> void:
	print("Creating settings file for the C.L.0.U.D plugin")
	# Check if the debug folder exists
	const FODLER: String = "res://debug/"
	if not DirAccess.dir_exists_absolute(FODLER):
		# Create debug folder if it's missing
		DirAccess.make_dir_absolute(FODLER)
	
	# Check if plugin settings file exists
	const FILE: String = "plugin_settings.ini"
	if not FileAccess.file_exists(FODLER + FILE):
		# Create plugin settings file if it's missing
		var data: Dictionary = {
			"save_enabled": var_to_str(false),
		}
		var text: String = JSON.stringify(data, "\t")
		var file_access := FileAccess.open(FODLER + FILE, FileAccess.WRITE)
		# Save text to file
		file_access.store_string(text)
