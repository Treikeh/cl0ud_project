extends Resource
class_name ProfileData


enum DataTypes {
	NAME,
	BIRTHDAY,
	OCCUPATION,
	ADDRESS,
	LIKES,
	DISLIKES,
}

@export var data: Dictionary[DataTypes, ItemData]


func has_item(item: ItemData) -> bool:
	for type: DataTypes in data:
		if data[type] == item:
			return true
	return false
