extends RayCast3D


signal prompt_updated(prompt: String)


var can_interact: bool = true
var _interact_target: InteractArea3D

@onready var _player: Player = get_owner()


func _process(_delta: float) -> void:
	var target: InteractArea3D = null
	var prompt: String = ""
	
	if is_colliding() and can_interact:
		var collider: Node3D = get_collider()
		if collider is InteractArea3D:
			target = collider
			prompt = collider.prompt + "\n [E]"
	
	_interact_target = target
	prompt_updated.emit(prompt)


func try_interact() -> void:
	if _interact_target:
		_interact_target.interact(_player)
