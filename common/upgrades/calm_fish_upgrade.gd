extends Upgrade
class_name CalmFishUpgrade


@export var _upgrade_amount: float = 1.0


func apply_upgrade(player: Player) -> void:
	player.hook_mod += _upgrade_amount
