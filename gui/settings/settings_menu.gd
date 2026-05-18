class_name SettingsMenu
extends Control


signal closed


const SCENE_PATH: String = "res://gui/settings/settings_menu.tscn"

@onready var _apply_button: Button = %ApplyButton


static func create() -> SettingsMenu:
	return load(SCENE_PATH).instantiate()


func _ready() -> void:
	_load_video_settings()
	_load_camera_settings()
	_load_audio_settings()


func _process(_delta: float) -> void:
	_apply_button.disabled = not _has_settings_changed()


func close() -> void:
	SettingsManager.apply_video_settings()
	SettingsManager.apply_camera_settings()
	SettingsManager.apply_audio_settings()
	
	closed.emit()
	queue_free()


func _apply_settings() -> void:
	for setting: String in _new_video_settings:
		SettingsManager.set_video_setting(setting, _new_video_settings[setting])
	
	for setting: String in _new_camera_settings:
		SettingsManager.set_camera_setting(setting, _new_camera_settings[setting])
	
	for setting: String in _new_audio_settings:
		SettingsManager.set_audio_setting(setting, _new_audio_settings[setting])
	
	SettingsManager.save_settings()
	
	_old_video_settings = _new_video_settings.duplicate()
	_old_camera_settings = _new_camera_settings.duplicate()
	_old_audio_settings = _new_audio_settings.duplicate()


func _reset_settings() -> void:
	const DEFAULTS: Dictionary = SettingsManager.DEFAULTS
	
	# Video
	_on_display_mode_changed(DEFAULTS.VIDEO.DISPLAY_MODE)
	_on_vsync_changed(DEFAULTS.VIDEO.VSYNC_MODE)
	_on_fps_changed(DEFAULTS.VIDEO.MAX_FPS)
	
	# Camera
	_on_cam_sens_changed(DEFAULTS.CAMERA.SENSITIVITY)
	_on_cam_fov_changed(DEFAULTS.CAMERA.FOV)
	
	# Audio
	_on_master_volume_changed(DEFAULTS.AUDIO.MASTER_VOLUME)
	_on_music_volume_changed(DEFAULTS.AUDIO.MUSIC_VOLUME)
	_on_effects_volume_changed(DEFAULTS.AUDIO.EFFECTS_VOLUME)
	_on_ambience_volume_changed(DEFAULTS.AUDIO.AMBIENCE_VOLUME)
	_on_ui_volume_changed(DEFAULTS.AUDIO.UI_VOLUME)


func _has_settings_changed() -> bool:
	var video: bool = _new_video_settings != _old_video_settings
	var camera: bool = _new_camera_settings != _old_camera_settings
	var audio: bool = _new_audio_settings != _old_audio_settings
	return video or camera or audio


#region Video


var _old_video_settings: Dictionary
var _new_video_settings: Dictionary

@onready var _display_mode_options: OptionButton = %DisplayModeOptions
@onready var _vsync_options: OptionButton = %VsyncOptions
@onready var _fps_slider: HSlider = %FpsSlider
@onready var _fps_spin_box: SpinBox = %FpsSpinBox


func _load_video_settings() -> void:
	var video_settings: Dictionary = SettingsManager.get_video_settings()
	_old_video_settings = video_settings.duplicate()
	_new_video_settings = video_settings.duplicate()
	
	_display_mode_options.selected = int(video_settings.DISPLAY_MODE)
	_display_mode_options.item_selected.connect(_on_display_mode_changed)
	
	_on_vsync_changed(int(video_settings.VSYNC_MODE))
	_vsync_options.item_selected.connect(_on_vsync_changed)
	
	_on_fps_changed(video_settings.MAX_FPS)
	_fps_slider.value_changed.connect(_on_fps_changed)
	_fps_spin_box.value_changed.connect(_on_fps_changed)


func _on_display_mode_changed(index: int) -> void:
	_new_video_settings.DISPLAY_MODE = index
	_display_mode_options.selected = index
	SettingsManager.set_display_mode(index)


func _on_vsync_changed(index: int) -> void:
	_new_video_settings.VSYNC_MODE = index
	_vsync_options.selected = index
	SettingsManager.set_vsync_mode(index as DisplayServer.VSyncMode)
	
	# Disable fps slider if vsync is enabled
	var vsync_enabled: bool = index == DisplayServer.VSYNC_ENABLED
	_fps_slider.editable = not vsync_enabled
	_fps_spin_box.editable = not vsync_enabled
	if vsync_enabled:
		_on_fps_changed(DisplayServer.screen_get_refresh_rate())


func _on_fps_changed(value: float) -> void:
	_new_video_settings.MAX_FPS = int(value)
	_fps_slider.value = value
	_fps_spin_box.value = value


#endregion


#region Camera

var _old_camera_settings: Dictionary
var _new_camera_settings: Dictionary

@onready var _cam_sens_slider: HSlider = %CamSensSlider
@onready var _cam_sens_spin_box: SpinBox = %CamSensSpinBox
@onready var _cam_fov_slider: HSlider = %CamFovSlider
@onready var _cam_fov_spin_box: SpinBox = %CamFovSpinBox


func _load_camera_settings() -> void:
	var camera_settings: Dictionary = SettingsManager.get_camera_settings()
	_old_camera_settings = camera_settings.duplicate()
	_new_camera_settings = camera_settings.duplicate()
	
	_on_cam_sens_changed(camera_settings.SENSITIVITY)
	_cam_sens_slider.value_changed.connect(_on_cam_sens_changed)
	_cam_sens_spin_box.value_changed.connect(_on_cam_sens_changed)
	
	_on_cam_fov_changed(camera_settings.FOV)
	_cam_fov_slider.value_changed.connect(_on_cam_fov_changed)
	_cam_fov_spin_box.value_changed.connect(_on_cam_fov_changed)


func _on_cam_sens_changed(value: float) -> void:
	_new_camera_settings.SENSITIVITY = value
	_cam_sens_slider.value = value
	_cam_sens_spin_box.value = value


func _on_cam_fov_changed(value: float) -> void:
	_new_camera_settings.FOV = value
	_cam_fov_slider.value = value
	_cam_fov_spin_box.value = value
	
	SettingsManager.fov_changed.emit(value)


#endregion


#region Audio

var _old_audio_settings: Dictionary
var _new_audio_settings: Dictionary

@onready var _master_volume_slider: HSlider = %MasterVolSlider
@onready var _master_volume_spin_box: SpinBox = %MasterVolSpinBox
@onready var _music_volume_slider: HSlider = %MusicVolSlider
@onready var _music_volume_spin_box: SpinBox = %MusicVolSpinBox
@onready var _effects_volume_slider: HSlider = %EffectsVolSlider
@onready var _effects_volume_spin_box: SpinBox = %EffectsVolSpinBox
@onready var _ambience_volume_slider: HSlider = %AmbienceVolSlider
@onready var _ambience_volume_spin_box: SpinBox = %AmbienceVolSpinBox
@onready var _ui_volume_slider: HSlider = %UiVolSlider
@onready var _ui_volume_spin_box: SpinBox = %UiVolSpinBox


func _load_audio_settings() -> void:
	var audio_settings: Dictionary = SettingsManager.get_audio_settings()
	_old_audio_settings = audio_settings.duplicate()
	_new_audio_settings = audio_settings.duplicate()
	
	_on_master_volume_changed(audio_settings.MASTER_VOLUME)
	_master_volume_slider.value_changed.connect(_on_master_volume_changed)
	_master_volume_spin_box.value_changed.connect(_on_master_volume_changed)
	
	_on_music_volume_changed(audio_settings.MUSIC_VOLUME)
	_music_volume_slider.value_changed.connect(_on_music_volume_changed)
	_music_volume_spin_box.value_changed.connect(_on_music_volume_changed)
	
	_on_effects_volume_changed(audio_settings.EFFECTS_VOLUME)
	_effects_volume_slider.value_changed.connect(_on_effects_volume_changed)
	_effects_volume_spin_box.value_changed.connect(_on_effects_volume_changed)
	
	_on_ambience_volume_changed(audio_settings.AMBIENCE_VOLUME)
	_ambience_volume_slider.value_changed.connect(_on_ambience_volume_changed)
	_ambience_volume_spin_box.value_changed.connect(_on_ambience_volume_changed)
	
	_on_ui_volume_changed(audio_settings.UI_COLUME)
	_ui_volume_slider.value_changed.connect(_on_ui_volume_changed)
	_ui_volume_spin_box.value_changed.connect(_on_ui_volume_changed)


func _on_master_volume_changed(value: float) -> void:
	_new_audio_settings.MASTER_VOLUME = value
	_master_volume_slider.value = value
	_master_volume_spin_box.value = value


func _on_music_volume_changed(value: float) -> void:
	_new_audio_settings.MUSIC_VOLUME = value
	_music_volume_slider.value = value
	_music_volume_spin_box.value = value


func _on_effects_volume_changed(value: float) -> void:
	_new_audio_settings.EFFECTS_VOLUME = value
	_effects_volume_slider.value = value
	_effects_volume_spin_box.value = value


func _on_ambience_volume_changed(value: float) -> void:
	_new_audio_settings.AMBIENCE_VOLUME = value
	_ambience_volume_slider.value = value
	_ambience_volume_spin_box.value = value


func _on_ui_volume_changed(value: float) -> void:
	_new_audio_settings.UI_VOLUME = value
	_ui_volume_slider.value = value
	_ui_volume_spin_box.value = value

#endregion
