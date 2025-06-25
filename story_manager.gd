class_name StoryManager
extends Node
@export var _ink_player:InkPlayer
@export var commandManagerHandle:Control

var currentStoryText:String
var currentChoices:Array
var currentChoiceIndex:int = -1

var currentCommand:String = ""
var lastCommand:String = ""

var genericAvailable:bool = false
var genericChoices:Array

var locationAvailable:bool = false
var locationName:String = ""
var locationChoices:Array

var savedState:String
var lastChoiceMade:String = "Cool"
var cachedState

var allGlobalVariables:Dictionary

var previousStates:Array[Dictionary]

func _ready():
	_ink_player.connect("loaded",_story_loaded)
	_ink_player.connect("continued",_continued)
	_ink_player.connect("prompt_choices",_prompt_choices)
	_ink_player.connect("ended",_ended)
	
	Global.StoryChoiceMade.connect(OnMakeChoice)
	Global.OnMakeStoryChoice.connect(OnMakeChoice)
	Global.StoryTextCleared.connect(OnTextCleared)
	
	_ink_player.choice_made.connect(OnChoiceMade)
	
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
	if !successfully:
		return
	print("Story is loaded!")
	_ink_player.continue_story()


func _continued(text, tags):
	if (text == ""):
		print("Text is empty.. returning")
		return
		
	#print("CONTINUING STORY ONTO: "+str(text))
	currentStoryText = text
	Global.StoryProgressed.emit()
	#print("CURRENT CHOIES: "+str(currentChoices))
	_ink_player.continue_story()

func SaveAllVariables():
	var gVars = _ink_player._story.variables_state._global_variables
	for obj in gVars:
		allGlobalVariables[obj["name"]] = _ink_player.get_variable(obj["name"])
		
	
func LoadAllVariables():
	for name in allGlobalVariables.keys():
		_ink_player.set_variable(name,allGlobalVariables[name])

func resetState(wVars:bool = false):
	if wVars:
		SaveAllVariables()
	_ink_player.reset()
	if wVars:
		LoadAllVariables()

func forceChoices():
	currentChoices = []
	for c in _ink_player.current_choices:
		print(c.text)
		currentChoices.append(c.text)

func _prompt_choices(choices):
	currentChoices = []
	if !choices.is_empty():
		for c in range(choices.size()):
			#print("Adding choice: "+str(c.text))
			currentChoices.append(choices[c].text)
		
		# In a real-world scenario, _select_choice' could be
		# connected to a signal, like 'Button.pressed'.
		#_select_choice(0)

func _path_chosen(argument, path):
	addStateToHistory(path)
	#print("Argument: "+str(argument)+" - Path: "+str(path))	

func _ended():
	print("The End")

func OnChoiceMade(choice):
	pass

func OnMakeChoice(index):
	currentChoiceIndex = index
	#addStateToHistory()

func OnTextCleared():	
	_select_choice(currentChoiceIndex)

func addStateToHistory(choice):
	#Add to undo queue
	if (choice == "" or choice == null):
		return
	
	if (previousStates.size() > 0):
		#var prSjs:JSON = JSON.new()
		var dataA = previousStates.back()["state"]#prSjs.parse_string(previousStates.back()["state"])
		var dataB = choice#prSjs.parse_string(choice)
		
		if (dataA != dataB):
			var state:Dictionary = {
				"state": choice,
				"stateName": lastCommand,
				"choices": _ink_player.get_current_choices().duplicate(),
				"fullState": cachedState
			}
			previousStates.append(state)
		else:
			pass
	else:
		var state:Dictionary = {
			"state": choice,
			"stateName": currentCommand,
			"choices": _ink_player.get_current_choices().duplicate(),
			"fullState": _ink_player.get_state()
		}
		previousStates.append(state)
		#print("Prev states: "+str(previousStates))
	var u = ""
	for a in previousStates:
		u += str(a["state"])+" \n"
	Global.DisplayDebugText3.emit(u)

func _select_choice(index):
	var u = ""
	for a in previousStates:
		u += str(a["state"])+" \n"
	Global.DisplayDebugText3.emit(u)
	#Add to undo queue
	#previousStates.append(_ink_player.get_state())
	#lastChoiceMade = ""
	addStateToHistory(lastChoiceMade)
	if (index != -1):
		if (_ink_player.current_choices.size() > 0):
			cachedState = _ink_player.get_state()
			lastChoiceMade = _ink_player.current_choices[index].path_string_on_choice
			#cachedState = _ink_player.get_state()
			Global.DisplayDebugText2.emit("Assigning last choice at: "+str(lastChoiceMade))
		else:
			pass
	
	#_ink_player.choose_path(currentChoices[index].path_string_on_choice)
		_ink_player.choose_choice_index(index)
	_ink_player.continue_story()

func OnGetState():
	savedState = _ink_player.get_state()
	#var a = _ink_player.get_current_path()

func OnGoBack():
	var u = ""
	for a in previousStates:
		u += "States. Ind: "+str(previousStates.find(a))+" - Previous:  "+str(a["state"])+" \n"
	Global.DisplayDebugText3.emit(u)
	
	if (previousStates.size() > 0):
		var tmpState = previousStates[previousStates.size()-1].duplicate()
		previousStates.remove_at(previousStates.size()-1)

		_ink_player.reset()
		_ink_player.choose_path(tmpState["state"])
		_ink_player.continue_story()

		_prompt_choices(tmpState['choices'])
	
		print("Choices: "+str(_ink_player.get_current_choices()))
		Global.StoryProgressed.emit()
		Global.CommandMade.emit(tmpState["stateName"])
		lastChoiceMade = tmpState["state"]
		#_continued(_ink_player.get_current_text(),null)
	else:
		Global.TextPopup.emit("At the start of time...",commandManagerHandle.commandAreaHandle.global_position + (commandManagerHandle.commandAreaHandle.size / 2))

func jumpToPath(p):
	#lastChoiceMade = _ink_player.get_current_path()
	addStateToHistory(lastChoiceMade)
	resetState(true)
	_ink_player.choose_path(p)
	_ink_player.continue_story()
	Global.StoryProgressed.emit()

func OnLocationEncountered(loc:String):
	await get_tree().process_frame
	print("ENCOUNTERED RULE: LOCATION")
	if (loc == locationName):
		return
		
	locationAvailable = true
	locationName = loc
	locationChoices = []
	for c in _ink_player.get_current_choices().duplicate():
		locationChoices.append({
			"text": c.text,
			"path": c.path_string_on_choice
		})
		
func OnRuleEncountered(rule:String):
	await get_tree().process_frame
	match rule:
		"generic":
			print("ENCOUNTERED RULE: GENERIC")
			genericAvailable = true
			genericChoices.clear()
			for c in _ink_player.get_current_choices():
				genericChoices.append({
					"text": c.text,
					"path": c.path_string_on_choice
				})
			Global.StoryChoiceMade.emit(0)
		"clearHistory":
			print("ENCOUNTERED RULE: HISTORY CLEAR")
			previousStates = []
			#lastChoiceMade = ""

func OnCommandMade(com:String):
	lastCommand = currentCommand
	currentCommand = com
	pass

func OnSetSate():
	OnGoBack()
