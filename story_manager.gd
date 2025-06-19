class_name StoryManager
extends Node
@export var _ink_player:InkPlayer

var currentStoryText:String
var currentChoices:Array
var currentChoiceIndex:int = -1


func _ready():
	_ink_player.connect("loaded",_story_loaded)
	_ink_player.connect("continued",_continued)
	_ink_player.connect("prompt_choices",_prompt_choices)
	_ink_player.connect("ended",_ended)
	
	Global.StoryChoiceMade.connect(OnMakeChoice)
	Global.OnMakeStoryChoice.connect(OnMakeChoice)
	Global.StoryTextCleared.connect(OnTextCleared)
	
	#_ink_player.connect("loaded", self, "_story_loaded")
	#_ink_player.connect("continued", self, "_continued")
	#_ink_player.connect("prompt_choices", self, "_prompt_choices")
	#_ink_player.connect("ended", self, "_ended")
	_ink_player.create_story()


func _story_loaded(successfully: bool):
	if !successfully:
		return

	print("Story is loaded!")
	_ink_player.continue_story()


func _continued(text, tags):
	if (text == ""):
		print("Text is empty.. returning")
		return
		
	print(text)
	currentStoryText = text
	Global.StoryProgressed.emit()
	_ink_player.continue_story()


func _prompt_choices(choices):
	currentChoices = []
	if !choices.is_empty():
		for c in choices:
			print("Adding choice: "+str(c.text))
			currentChoices.append(c.text)
		
		# In a real-world scenario, _select_choice' could be
		# connected to a signal, like 'Button.pressed'.
		#_select_choice(0)


func _ended():
	print("The End")


func OnMakeChoice(index):
	currentChoiceIndex = index

func OnTextCleared():
	_select_choice(currentChoiceIndex)

func _select_choice(index):
	_ink_player.choose_choice_index(index)
	_ink_player.continue_story()
