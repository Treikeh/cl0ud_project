extends Upgrade
class_name ThrowForceUpgrade


func apply_upgrade(player: Player) -> void:
	player.throw_upgrade_level += 1
