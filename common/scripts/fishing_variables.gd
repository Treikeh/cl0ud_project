extends Resource
class_name FishingVariables


@export_group("Fishing")
@export var throw_charge_speed: float = 2.0
@export var throw_charge_curve: Curve
@export var base_throw_force: float = 10.0
## How much the throw force should be increased at each upgrade level.
## Value is force, Domain is upgrade level
@export var throw_force_upgrade_curve: Curve
## Min time the player has to wait before a fish gets hooked
@export var min_wait_time: float = 5.0
## Max time the palyer has to wait before a fish gets hooked
@export var max_wait_time: float = 7.5


@export_group("Catch minigame")
## How big the target should be at different throw distances.
## Value is size, Domain is throw distance.
@export var target_area_size_curve: Curve
## How fast the cursor should move at different throw distances.
## Value is speed, Domain is throw distance.
@export var cursor_speed_curve: Curve


@export_group("Reel inn minigame")
## The size (in deg) of the hit area at different throw distances.
## Value is size, Domain is throw distance.
@export var hit_area_size_curve: Curve
## How much the hit area should change its size (+ and -) over different throw distances.
## Value is size variation, Domain is throw distance.
#@export var hit_area_size_variation_curve: Curve
## How often the hit area should change size at different throw distances.
#@export var hit_area_size_variation_interval_curve: Curve
## How fast the hit area should move over the course of different throw distances.
@export var hit_area_move_speed_curve: Curve
@export var value_decrase_speed_curve: Curve
@export var value_increase_speed_curve: Curve
@export var fish_type_move_maps: Dictionary[Fish.Type, Noise]
@export var fish_type_move_speed_curve: Curve
