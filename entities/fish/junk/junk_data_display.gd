extends FishDataDisplay


@export var _junk_label: RichTextLabel


func with_data(data: FishData) -> FishDataDisplay:
	if data is JunkData:
		_junk_label.text = data.get_random_text()
	return self
