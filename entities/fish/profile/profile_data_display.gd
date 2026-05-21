extends FishDataDisplay


@export var name_label: Label
@export var occupation_label: Label
@export var age_label: Label
@export var address_label: Label
@export var likes_label: Label
@export var dislikes_label: Label


func with_data(data: FishData) -> FishDataDisplay:
	if data is ProfileFishData:
		name_label.text = data.name
		occupation_label.text = data.occupation
		age_label.text = data.birthday
		address_label.text = data.address
		likes_label.text = data.likes
		dislikes_label.text = data.dislikes
	return self
