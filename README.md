# Dialogue Label
This is a simple RichTextLabel extension for displaying dynamic dialogues.

# Status
Dialogue Label is in testing. Bugs may appear, so feel free to open Issues and give feedback.

# New tags
```[spd 1.5]```	change text speed to 1.5 symbols/frame <br />
```[inst 5]```	instantly display next 5 symbols<br />
```[snd 0]```	choose first sound bite in sound bite list<br />
```[snd -1]``` turn off sound bite<br />
```[wait 60]```	- delay for 60 frames<br />
these tags __should not be closed__<br />
you don't have to use __spd__ and __snd__ tags in beginning of each message. These properties are persistent.
# Example
```
[color=gray][inst 13]!!!warning!!![/color]
[spd 1.5][snd 0]fast text with... [wait 60]sound bite 0
[spd 0.1][snd -1]slow text without sound bite
```
# Signals
|signal| meaning|
|---|---|
|dialogue_started| emits when dialogue starts|
|message_next| emits at the beginning of message rendering|
|dialogue_ended | emits when dialogue ends|
|message_finished | emits in the end of message rendering|

# Variables
| variable| meaning|
|---|---|
| messages | array of strings to display|
| sound_files | array of sound bite files, used in __[snd]__ tag|
| text_speed | default speed of text|
| active | current state of typing|
| message_id | index of current message|

# Functions
|function|meaning|
|---|---|
| get_current_message() | returns current message with all tags|
| stop_dialogue() | stops rendering of dialogue|
| change_messages(Array) | changes messages. Also resets message_id to 0 |
| start_dialogue()| starts the dialogue|
| next_message()| renders next message|
| skip_message()| displays current message instantly|

# Known issues
Malformed bbcode tags may lead to bugs. Be sure to use square brackets only for valid tags.
