extends FishDataDisplay


@export var _message_root: VBoxContainer
var _data: MessageData

func with_data(data: FishData) -> FishDataDisplay:
	if data is MessageData:
		_data = data
	return self


func _ready() -> void:
	for message: Dictionary in _data.messages:
		# Get label text
		var text: String = message.WHO + "\n"
		for line: String in message.LINES:
			text += line + "\n"
		
		# Add label
		var label := RichTextLabel.new()
		label.text = text
		label.fit_content = true
		label.bbcode_enabled = true
		_message_root.add_child(label)
		
		# Set alignment
		if message.WHO == _data.recipient:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		
		if message.WHO == "SYSTEM":
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
