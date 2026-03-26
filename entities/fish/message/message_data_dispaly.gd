extends FishDataDispaly


@export var _sender_label: Label
@export var _recipient_label: Label


func with_data(data: FishData) -> FishDataDispaly:
	if data is MessageData:
		_sender_label.text = data.sender
		_recipient_label.text = data.recipient
	return self
