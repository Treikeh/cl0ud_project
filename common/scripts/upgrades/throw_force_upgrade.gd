extends Upgrade
class_name ThrowForceUpgrade

@export var _upgrade_amount: float = 1.0


func apply_upgrade(player: Player) -> void:
	player.throw_force += _upgrade_amount
