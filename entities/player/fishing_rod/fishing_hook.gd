extends RigidBody3D
class_name FishingHook


signal hook_hit_water


const FISH_SCENE: PackedScene = preload("uid://i5dq3bivh8i0")

@export var _hook_marker: Marker3D

var hooked_fish: Fish

var _loot_pool: LootPool


func hit_water(loot_pool: LootPool) -> void:
	_loot_pool = loot_pool
	gravity_scale = 0.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	hook_hit_water.emit()


func spawn_fish() -> void:
	# Spawn a fish on the hook
	hooked_fish = FISH_SCENE.instantiate().with_data(_loot_pool)
	_hook_marker.add_child(hooked_fish)
