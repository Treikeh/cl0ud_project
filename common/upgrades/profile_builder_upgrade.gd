extends Upgrade
class_name ProfileBuilderUpgrade


signal profile_builder_bought


func apply_upgrade(_player: Player) -> void:
	profile_builder_bought.emit()
