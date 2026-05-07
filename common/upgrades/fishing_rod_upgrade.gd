extends Upgrade
class_name FishingRodUpgrade


func apply_upgrade(player: Player) -> void:
	player.fishing_rod.show()
	player.fishing_rod.process_mode = Node.PROCESS_MODE_INHERIT
