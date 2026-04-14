extends Node3D


@export var _anim_tree: AnimationTree

var throw_charge: float = 0.0 
var fishing_state: FishingRod.FishingState
var fish_dir: Vector2


func _process(_delta: float) -> void:
	_anim_tree.set("parameters/SM/conditions/idle", fishing_state == FishingRod.FishingState.IDLE)
	_anim_tree.set("parameters/SM/conditions/waiting", fishing_state == FishingRod.FishingState.WAITING)
	_anim_tree.set("parameters/SM/conditions/fish_hooked", fishing_state == FishingRod.FishingState.FISH_HOOKED)
	_anim_tree.set("parameters/SM/conditions/reel_inn", fishing_state == FishingRod.FishingState.REEL_IN)
	
	_anim_tree.set("parameters/SM/ReadyThrow/blend_position", throw_charge)
	_anim_tree.set("parameters/SM/FishHooked/blend_position", fish_dir)
