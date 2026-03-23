extends Control


@export var _inventory_menu: Control
@export var minigames_root: Control
@export var _interact_prompt: Label

var _player: Player


func with_data(player: Player) -> Control:
	_player = player
	return self


func _ready() -> void:
	# Setup inventory
	_inventory_menu.setup(_player.inventory)
	_inventory_menu.hide()
	
	# Setup minigames
	minigames_root.reel_inn_minigame.player = _player
	_player.fish_hooked.connect(minigames_root.start_minigames)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if _inventory_menu.visible:
			_inventory_menu.close()
		else:
			_inventory_menu.open()


func on_interact_prompt_updated(prompt: String) -> void:
	_interact_prompt.text = prompt
