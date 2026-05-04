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
