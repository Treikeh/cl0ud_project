extends FishDataDisplay


@export var _text_label: Label


func with_data(data: FishData) -> FishDataDisplay:
	if data is NoteData:
		_text_label.text = data.text
	return self
