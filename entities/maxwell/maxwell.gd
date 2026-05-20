extends Node3D


@export var _anim: AnimationPlayer
@export var _pet_sfx: FmodEventEmitter3D


func _on_interact_area_3d_interacted(player: Player) -> void:
	#if player.fishing_rod._hook.hooked_fish != null:
	#	player.fishing_rod._hook.hooked_fish.queue_free()
	
	if not _anim.is_playing():
		_anim.play("pet")
		_pet_sfx.play_one_shot()
