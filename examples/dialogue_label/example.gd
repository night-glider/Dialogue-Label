extends Control

@onready var anim = $AnimationPlayer

@onready var dialogue = $Dialogue

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	anim.play("changeColor")

func _process(_delta):
	if dialogue.message_id in [2,4,6,12]:
		if Input.is_action_just_pressed("ui_accept"):
			dialogue.next_message()
	
	if Input.is_action_just_pressed("ui_cancel"):
		dialogue.skip_message()
	
func startDialogue():
	dialogue.start_dialogue()


func onMessageFinished():
	if dialogue.message_id in [2,4,6,12]:
		return
		
	if dialogue.message_id == 7:
		anim.play("changeColorBack")
	
	if dialogue.message_id == 8:
		anim.play("changeColor_2")
		
	dialogue.next_message()


func onDialogueEnded():
	get_tree().quit()
