extends FishDataDispaly


@export var _from_label: Label
@export var _to_label: Label
@export var _subject_label: Label
@export var _content_label: Label


func with_data(data: FishData) -> FishDataDispaly:
	if data is MailData:
		_from_label.text = data.from
		_to_label.text = data.to
		_subject_label.text = data.subject
		_content_label.text = data.content
	return self
