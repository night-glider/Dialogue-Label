extends RichTextLabel
class_name DialogueLabel

@export_multiline var messages: Array[String] = ["HELLO_WORLD"]
@export var sound_files: Array[AudioStream] = []
@export var text_speed = 0.5

signal dialogue_started
signal message_next
signal dialogue_ended
signal message_finished

var active := false
var message_id := 0

var chars_to_display := 0.0
var tags := []
var delay_frames := 0
var audio_player := AudioStreamPlayer.new()


func _init():
	bbcode_enabled = true


func _ready():
	text = ""
	add_child(audio_player)


func get_current_message() -> String:
	return messages[message_id]


func stop_dialogue():
	text = ""

	emit_signal("dialogue_ended")


func change_messages(new_array: Array):
	messages = new_array.duplicate()

	message_id = 0
	active = false


func start_dialogue():
	message_id = -1

	if messages.is_empty():
		push_error("no messages in DialogueLabel ", name)
		return

	next_message()
	emit_signal("dialogue_started")


func next_message():
	message_id += 1
	visible_characters = 0
	visible_ratio = 0

	if message_id >= messages.size():
		active = false
		emit_signal("dialogue_ended")
		return

	tags = _parse_custom_tags(messages[message_id])
	parse_bbcode(tags.pop_front())
	active = true
	emit_signal("message_next")


func skip_message():
	visible_ratio = 1


func _parse_custom_tags(str: String) -> Array:
	var result = [str]

	var regex = RegEx.create_from_string(
		"\\[(?<tag_name>inst|spd|snd|wait) (?<tag_digit>-?[0-9]+(\\.[0-9]+)?)\\]"
	)
	for regex_match in regex.search_all(str):
		# Insert a new tag element
		result.append(
			{
				"name": regex_match.get_string("tag_name"),
				"pos": regex_match.get_start(),
				"value": regex_match.get_string("tag_digit")
			}
		)

		# Remove the tag from the original string
		var splitted_str = result[0].split(regex_match.get_string(), true, 1)
		result[0] = splitted_str[0] + splitted_str[1]

	return result


func _advance_text():
	if not active:
		return

	if delay_frames > 0:
		delay_frames -= 1
		return

	if visible_ratio >= 1:
		active = false
		emit_signal("message_finished")
		return

	chars_to_display += text_speed
	if floor(chars_to_display) >= 1:
		audio_player.play()
	visible_characters += floor(chars_to_display)
	chars_to_display -= floor(chars_to_display)

	if tags.is_empty():
		return

	if tags[0]["pos"] <= visible_characters:
		visible_characters = tags[0]["pos"]
		if tags[0]["name"] == "inst":
			visible_characters += int(tags[0]["value"])
		elif tags[0]["name"] == "spd":
			text_speed = float(tags[0]["value"])
		elif tags[0]["name"] == "snd":
			audio_player.stream = sound_files[int(tags[0]["value"])]
		elif tags[0]["name"] == "wait":
			delay_frames = int(tags[0]["value"])
		tags.pop_front()


func _process(delta):
	_advance_text()
