extends Control
# Credits: StayAtHomeDev - https://www.youtube.com/watch?v=QKAuacUG0y4


enum State {
	DEFAULT,
	LOADING,
}


@export var _fade_in_time: float = 1.0
@export var _fade_out_time: float = 1.0
## How long a splash screen is visible on screen
@export var _pause_time: float = 1.5
## How much time is between different splash screens
@export var _interval_time: float = 0.5
@export var _splash_screens_container: Control

var _state: State = State.DEFAULT
var _splash_screens: Array[Node] = []


func _ready() -> void:
	_get_screens()
	_fade_between_screens()


func _input(event: InputEvent) -> void:
	# Load level when pressing ESC
	if event.is_action_pressed("pause"):
		_load_level()


func _get_screens() -> void:
	_splash_screens = _splash_screens_container.get_children()
	# Make all the screens transparent
	for screen: Control in _splash_screens:
		screen.modulate = Color.TRANSPARENT


func _fade_between_screens() -> void:
	for screen: Control in _splash_screens:
		var tween = create_tween()
		tween.tween_interval(_interval_time)
		tween.tween_property(screen, "modulate", Color.WHITE, _fade_in_time)
		tween.tween_interval(_pause_time)
		tween.tween_property(screen, "modulate", Color.TRANSPARENT, _fade_out_time)
		await tween.finished
	_load_level()


func _load_level() -> void:
	if _state == State.DEFAULT:
		_state = State.LOADING
		LevelManager.load_level(_get_current_level())


func _get_current_level() -> String:
	var data: Dictionary = SaveManager.get_save_data("glboals")
	if data.is_empty():
		return "res://levels/days/day_01.tscn"
	return data.current_level
