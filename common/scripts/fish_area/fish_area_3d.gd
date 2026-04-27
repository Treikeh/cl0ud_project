extends Area3D


@export_enum("DEFAULT", "TOILET") var _loot_table: String = "DEFAULT"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is FishingHook:
		body.hit_water(_loot_table)
