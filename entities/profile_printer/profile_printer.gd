extends Node3D


enum State{
	EMPTY,
	PRINTING,
	DONE,
}


const PRINTER_MENU_SCENE: PackedScene = preload("uid://daoulaw7h8y4p")


@export var _terminal_collision: CollisionShape3D
@export var _printer_collision: CollisionShape3D

@export_group("SFX")
@export var _print_sfx: FmodEventEmitter3D
@export var _open_menu_sfx: FmodEventEmitter2D
@export var _close_menu_sfx: FmodEventEmitter2D

var _state: State = State.EMPTY
var _paper_item: ItemData


func _ready() -> void:
	$PaperMesh.hide()


func _on_interacted(player: Player) -> void:
	match _state:
		State.EMPTY:
			_open_menu(player)
		State.DONE:
			_pick_up_piece(player)


func _open_menu(player: Player) -> void:
	player.input.set_enabled(false)
	# Spawn printer menu
	var printer_menu: Control = PRINTER_MENU_SCENE.instantiate().with_data(player.inventory)
	add_child(printer_menu)
	printer_menu.closed.connect(_on_menu_closed.bind(player))
	printer_menu.fish_printed.connect(_on_fish_printed)
	_open_menu_sfx.play_one_shot()


func _on_menu_closed(player: Player) -> void:
	player.input.set_enabled.call_deferred(true)
	player.update_look_position(Vector3.ZERO)
	_close_menu_sfx.play_one_shot()


func _on_fish_printed(item_data: ItemData) -> void:
	_state = State.PRINTING
	_terminal_collision.disabled = true
	_paper_item = item_data
	
	#TODO: Play printing animation
	await get_tree().create_timer(1.0).timeout
	
	_on_printing_finished()


func _on_printing_finished() -> void:
	_state = State.DONE
	_printer_collision.disabled = false
	$PaperMesh.show()


func _pick_up_piece(player: Player) -> void:
	_state = State.EMPTY
	_printer_collision.disabled = true
	_terminal_collision.disabled = false
	player.piece_inventory.add_item(_paper_item)
	$PaperMesh.hide()
	_print_sfx.play_one_shot()
