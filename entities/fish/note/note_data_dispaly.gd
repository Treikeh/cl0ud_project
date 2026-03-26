extends FishDataDispaly


@export var _text_label: Label


func with_data(data: FishData) -> FishDataDispaly:
	if data is NoteData:
		_text_label.text = data.text
	return self
