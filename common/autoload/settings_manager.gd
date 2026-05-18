extends Node


signal video_settings_changed
signal camera_settings_changed
signal audio_settings_changed
@warning_ignore("unused_signal")
signal fov_changed(fov: float)


enum DISPLAY_MODE {
	FULLSCREEN,
	BORDERLESS_FULLSCREEN,
	WINDOWED,
	BORDERLESS_WINDOWED,
}


const FILE_NAME: String = "settings.ini"
const DEFAULTS: Dictionary[String, Variant] = {
	"VIDEO": {
		"DISPLAY_MODE": DISPLAY_MODE.BORDERLESS_FULLSCREEN,
		"VSYNC_MODE": DisplayServer.VSYNC_ENABLED,
		"MAX_FPS": 60.0,
	},
	"CAMERA": {
		"SENSITIVITY": 0.1,
		"FOV": 90.0,
	},
	"AUDIO": {
		"MASTER_VOLUME": 1.0,
		"MUSIC_VOLUME": 1.0,
		"EFFECTS_VOLUME": 1.0,
		"AMBIENCE_VOLUME": 1.0,
		"UI_VOLUME": 1.0,
	},
}


var _settings: Dictionary = {}

@onready var _file_path: String = Globals.get_data_dir() + FILE_NAME


func _ready() -> void:
	_load_settings_from_file()
	
	apply_video_settings()
	apply_camera_settings()
	apply_audio_settings()


func _load_settings_from_file() -> void:
	_settings = Globals.load_data_from_file(_file_path)
	if _settings.is_empty():
		_settings = DEFAULTS.duplicate_deep()


func save_settings() -> void:
	Globals.save_data_to_file(_file_path, _settings)



#region VIDEO

func set_video_setting(setting: String, value: Variant) -> void:
	_settings["VIDEO"][setting] = value
	video_settings_changed.emit()


func get_video_settings() -> Dictionary:
	return _settings["VIDEO"].duplicate()
 

func apply_video_settings() -> void:
	var video_settings: Dictionary = get_video_settings()
	if video_settings.is_empty():
		return
	
	set_display_mode(video_settings.DISPLAY_MODE)
	set_vsync_mode(video_settings.VSYNC_MODE)
	Engine.max_fps = int(video_settings.MAX_FPS)


func set_display_mode(display_mode: DISPLAY_MODE) -> void:
	match display_mode:
		DISPLAY_MODE.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DISPLAY_MODE.BORDERLESS_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DISPLAY_MODE.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DISPLAY_MODE.BORDERLESS_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func set_vsync_mode(vsync_mode: DisplayServer.VSyncMode) -> void:
	DisplayServer.window_set_vsync_mode(vsync_mode)

#endregion



#region CAMERA

func set_camera_setting(setting: String, value: Variant) -> void:
	_settings["CAMERA"][setting] = value
	camera_settings_changed.emit()


func get_camera_settings() -> Dictionary:
	return _settings["CAMERA"].duplicate()
 

func apply_camera_settings() -> void:
	var camera_settings: Dictionary = get_camera_settings()
	if camera_settings.is_empty():
		return

#endregion



#region AUDIO

func set_audio_setting(setting: String, value) -> void:
	_settings["AUDIO"][setting] = value
	audio_settings_changed.emit()


func get_audio_settings() -> Dictionary:
	return _settings["AUDIO"].duplicate()


func apply_audio_settings() -> void:
	var audio_settings: Dictionary = get_audio_settings()
	if audio_settings.is_empty():
		return
	
	FmodServer.get_bus("bus:/").volume = audio_settings.MASTER_VOLUME
	FmodServer.get_bus("bus:/Music").volume = audio_settings.MUSIC_VOLUME
	FmodServer.get_bus("bus:/Actions").volume = audio_settings.EFFECTS_VOLUME
	FmodServer.get_bus("bus:/Ambience").volume = audio_settings.AMBIENCE_VOLUME
	FmodServer.get_bus("bus:/UI").volume = audio_settings.UI_VOLUME

#endregion
