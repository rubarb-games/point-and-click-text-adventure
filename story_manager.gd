extends Node
@export var _ink_player:InkPlayer


func _ready():
	_ink_player.connect("loaded",_story_loaded)
	_ink_player.connect("continued",_continued)
	_ink_player.connect("prompt_choices",_prompt_choices)
	_ink_player.connect("ended",_ended)
	
	#_ink_player.connect("loaded", self, "_story_loaded")
	#_ink_player.connect("continued", self, "_continued")
	#_ink_player.connect("prompt_choices", self, "_prompt_choices")
	#_ink_player.connect("ended", self, "_ended")
	print("Yeahboiiiiii!!!!")
	_ink_player.create_story()


func _story_loaded(successfully: bool):
	if !successfully:
		return

	print("Story is loaded!")
	_ink_player.continue_story()


func _continued(text, tags):
	print(text)
	print("Story continued!!!!")
	_ink_player.continue_story()


func _prompt_choices(choices):
	if !choices.empty():
		print(choices)
		print("There are choices!!!")
		# In a real-world scenario, _select_choice' could be
		# connected to a signal, like 'Button.pressed'.
		_select_choice(0)


func _ended():
	print("The End")


func _select_choice(index):
	_ink_player.choose_choice_index(index)
	_ink_player._continue_story()
