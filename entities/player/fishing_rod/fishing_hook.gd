extends RigidBody3D
class_name FishingHook


enum HookState {
	NORMAL,
	THROWN,
	IN_WATER,
}


signal hook_hit_water
signal fish_hooked


const FISH_SCENE: PackedScene = preload("uid://i5dq3bivh8i0")

@export var _hook_marker: Marker3D
@export var _fish_timer: Timer

var hooked_fish: Fish
var hook_state: HookState = HookState.NORMAL


func _ready() -> void:
	_fish_timer.timeout.connect(_on_fish_hooked)


func _on_fish_hooked() -> void:
	Globals.fish_hooked.emit()


func _on_fish_escaped() -> void:
	_fish_timer.start()


func hit_water() -> void:
	if hook_state == HookState.THROWN:
		hook_state = HookState.IN_WATER
		gravity_scale = 0.0
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		hook_hit_water.emit()
		_fish_timer.start()


func reset_hook() -> void:
	_fish_timer.stop()
	top_level = false
	linear_damp = 2.0
	gravity_scale = 1.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	rotation_degrees = Vector3.ZERO
	hook_state = HookState.NORMAL


func spawn_fish() -> void:
	# Spawn a fish on the hook
	hooked_fish = FISH_SCENE.instantiate()
	_hook_marker.add_child(hooked_fish)
