extends PanelContainer
class_name BuyEntry


signal pressed(buy_entry: BuyEntry)
signal bought(cost: int)


@export var _icon: TextureRect
@export var _name_label: Label
@export var _description_label: Label
@export var _cost_label: Label
@export var _bought_cover: ColorRect

var upgrade: Upgrade


func with_data(_upgrade: Upgrade) -> BuyEntry:
	upgrade = _upgrade
	return self


func _ready() -> void:
	# Setup entry
	_icon.texture = upgrade.icon
	_name_label.text = upgrade.name
	_description_label.text = upgrade.description
	_cost_label.text = str(upgrade.cost)
	
	_bought_cover.visible = upgrade.bought


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		pressed.emit(self)


func can_buy(currency: int) -> bool:
	return currency >= upgrade.cost and not upgrade.bought


func buy(player: Player) -> void:
	_bought_cover.show()
	upgrade.bought = true
	player.add_upgrade(upgrade)
	bought.emit(upgrade.cost)
