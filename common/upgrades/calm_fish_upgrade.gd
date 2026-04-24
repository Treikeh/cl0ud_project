extends Upgrade
class_name CalmFishUpgrade


func apply_upgrade(player: Player) -> void:
	player.calm_fish_upgrade_level += 1
