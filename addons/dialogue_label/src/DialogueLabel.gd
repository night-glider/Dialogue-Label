extends RichTextLabel
class_name DialogueLabel

@export_multiline var messages:Array[String] = ["HELLO_WORLD"]
@export var sound_files:Array[AudioStream] = []
@export var text_speed = 0.5


signal dialogue_started
signal message_next
signal dialogue_ended
signal message_finished

var active = false
var message_id = 0

var chars_to_display = 0.0
var tags = []
var delay_frames = 0
var audio_player = AudioStreamPlayer.new()

func _init():
	bbcode_enabled = true

func _ready():
	text = ''
	add_child(audio_player)
	
	if messages.is_empty():
		push_error("no messages in DialogueLabel ", name)

func get_current_message()->String:
	return messages[message_id]

func stop_dialogue():
	text = ""
	
	emit_signal("dialogue_ended")

func change_messages(new_array:Array):
	messages = new_array.duplicate()
	
	message_id = 0
	active = false

func start_dialogue():
	message_id = -1
	
	next_message()
	emit_signal("dialogue_started")

func next_message():
	message_id+=1
	visible_characters = 0
	visible_ratio = 0
	
	if message_id >= messages.size():
		active = false
		emit_signal("dialogue_ended")
		return
	
	parse_bbcode(messages[message_id])
	tags = _parse_custom_tags( get_parsed_text() )
	parse_bbcode(tags.pop_front())
	active = true
	emit_signal("message_next")

func skip_message():
	visible_ratio = 1

func _parse_custom_tags(str:String)->Array:
	var result = [""]
	var inside_tag = false
	var current_pos = 0
	var inside_tag_name = false
	var inside_tag_value = false
	var current_tag = ""
	var current_tag_value = ""
	
	for char in str:
		if inside_tag:
			if char == "]":
				inside_tag = false
				if current_tag in ["inst", "spd", "snd", "wait"]:
					result.append( {
						"name":current_tag, 
						"pos": current_pos,
						"value":current_tag_value} )
				else:
					push_error("Malformed bbcode tag '" + current_tag + "' in message " + str(message_id) + ". Please be sure to use square brackets only for valid bbcode tags, otherwise bugs may occur")
				
				current_tag = ""
				current_tag_value = ""
				continue
			if char == " ":
				inside_tag_name = false
				if current_tag in ["inst", "spd", "snd", "wait"]:
					inside_tag_value = true
				
				continue
			if inside_tag_name:
				current_tag+=char
				continue
			if inside_tag_value:
				current_tag_value+=char
				continue
			
			continue
		if char == "[":
			inside_tag = true
			inside_tag_name = true
			continue
		
		result[0] += char
		current_pos+=1
	
	return result
	

func _advance_text():
	if not active:
		return
		
	if delay_frames>0:
		delay_frames -=1
		return
		
	if visible_ratio >= 1:
		active = false
		emit_signal("message_finished")
		return
	
	chars_to_display+=text_speed
	if floor(chars_to_display) >= 1:
		audio_player.play()
	visible_characters+=floor(chars_to_display)
	chars_to_display-=floor(chars_to_display)
	
	if tags.is_empty():
		return
	
	if tags[0]["pos"] <= visible_characters:
		visible_characters = tags[0]["pos"]
		if tags[0]["name"] == "inst":
			visible_characters += int(tags[0]["value"])
		elif tags[0]["name"] == "spd":
			text_speed = float(tags[0]["value"])
		elif tags[0]["name"] == "snd":
			audio_player.stream = sound_files[ int(tags[0]["value"]) ]
		elif  tags[0]["name"] == "wait":
			delay_frames = int(tags[0]["value"])
		tags.pop_front()

func _process(delta):
	_advance_text()
