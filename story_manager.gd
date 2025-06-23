class_name StoryManager
extends Node
@export var _ink_player:InkPlayer
@export var commandManagerHandle:Control

var currentStoryText:String
var currentChoices:Array
var currentChoiceIndex:int = -1

var currentCommand:String

var genericAvailable:bool = false
var genericChoices:Array

var locationAvailable:bool = false
var locationName:String = ""
var locationChoices:Array

var savedState:String

var previousStates:Array[String]

func _ready():
	_ink_player.connect("loaded",_story_loaded)
	_ink_player.connect("continued",_continued)
	_ink_player.connect("prompt_choices",_prompt_choices)
	_ink_player.connect("ended",_ended)
	
	Global.StoryChoiceMade.connect(OnMakeChoice)
	Global.OnMakeStoryChoice.connect(OnMakeChoice)
	Global.StoryTextCleared.connect(OnTextCleared)
	
	Global.LocationEncountered.connect(OnLocationEncountered)
	Global.RuleEncountered.connect(OnRuleEncountered)
	Global.CommandMade.connect(OnCommandMade)
	
	Global.GoBack.connect(OnGoBack)
	
	#_ink_player.connect("loaded", self, "_story_loaded")
	#_ink_player.connect("continued", self, "_continued")
	#_ink_player.connect("prompt_choices", self, "_prompt_choices")
	#_ink_player.connect("ended", self, "_ended")
	#_ink_player.connect("path_chosen",self,"_path_chosen")
	_ink_player.path_choosen.connect(_path_chosen)
	_ink_player.create_story()

func _story_loaded(successfully: bool):
	Global.DisplayDebugText.emit("CONTINUE STORRR")
	if !successfully:
		return
	print("Story is loaded!")
	_ink_player.continue_story()


func _continued(text, tags):
	Global.DisplayDebugText.emit("CONTINUED STORY - LOOKING FOR TEXT")
	if (text == ""):
		print("Text is empty.. returning")
		return
		
	#print(text)
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

func _path_chosen(argument, path):
	print("Argument: "+str(argument)+" - Path: "+str(path))	

func _ended():
	print("The End")


func OnMakeChoice(index):
	currentChoiceIndex = index

func OnTextCleared():
	#Add to undo queue
	if (previousStates.size() > 0):
		var prSjs:JSON = JSON.new()
		var dataA = prSjs.parse_string(previousStates.back())
		var dataB = prSjs.parse_string(_ink_player.get_state())
		
		if (dataA["flows"]["DEFAULT_FLOW"]["outputStream"][0] != dataB["flows"]["DEFAULT_FLOW"]["outputStream"][0]):
			print("STATE: "+str(dataA["flows"]["DEFAULT_FLOW"]["outputStream"][0]))
			var state:Dictionary = {
				"state": _ink_player.get_state(),
				"stateName": currentCommand
			}
			previousStates.append(_ink_player.get_state())
	else:
		var state:Dictionary = {
			"state": _ink_player.get_state(),
			"stateName": currentCommand
		}
		previousStates.append(_ink_player.get_state())
	
	_select_choice(currentChoiceIndex)

func _select_choice(index):
	#Add to undo queue
	#previousStates.append(_ink_player.get_state())
	
	_ink_player.choose_choice_index(index)
	_ink_player.continue_story()

func OnGetState():
	savedState = _ink_player.get_state()

func OnGoBack():
	if (previousStates.size() > 0):
		var tmpState = previousStates.pop_back()
		_ink_player.set_state(tmpState["state"])
		print(previousStates)
		Global.DumpText.emit(false)
		Global.CommandMade.emit(tmpState["stateName"])
		
		_continued(_ink_player.get_current_text(),null)
	else:
		pass
		Global.TextPopup.emit("At the start of time...",commandManagerHandle.commandAreaHandle.global_position + (commandManagerHandle.commandAreaHandle.size / 2))

func OnLocationEncountered(loc:String):
	print("ENCOUNTERED RULE: LOCATION")
	if (locationName != loc):
		locationAvailable = true
		locationName = loc
		locationChoices = currentChoices
		
func OnRuleEncountered(rule:String):
	match rule:
		"generic":
			print("ENCOUNTERED RULE: GENERIC")
			genericAvailable = true
			genericChoices = currentChoices
			_select_choice(0)
		"historyClear":
			print("ENCOUNTERED RULE: HISOTYR CLEAR")
			previousStates = []

func OnCommandMade(com:String):
	currentCommand = com
	pass

func OnSetSate():
	OnGoBack()
