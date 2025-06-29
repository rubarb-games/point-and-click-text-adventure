class_name StoryManagerOLD
extends Node
@export var _ink_player:InkPlayer
@export var commandManagerHandle:Control

var currentStoryText:String
var currentChoices:Array
var currentChoiceIndex:int = -1
var pathJumpCached = false
var goBackCached = false
var pathToJumpTo:String = ""

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
var cachedCurrentPath:String = ""

var allGlobalVariables:Dictionary
var allVisitCounts:Dictionary

var firstLine:bool = false

var previousStates:Array[Dictionary]

var visistedChoices:Dictionary

func _ready():
	return
	
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
		
	if (firstLine):
		firstLine = false
	else:
		currentStoryText = text
		print("CONTINUING STORY ONTO: "+str(text))
	if (_ink_player.current_path != ""):
		cachedCurrentPath = _ink_player.current_path.split(".")[0]
		print("CachedPath is: "+str(cachedCurrentPath))
	#Global.StoryProgressed.emit()
	Global.StoryProgressed.emit()
	#print("CURRENT CHOIES: "+str(currentChoices))
	_ink_player.continue_story()

func prepNewLine():
	firstLine = true
	currentStoryText = ""
	#Global.DumpText.emit(false)

func SaveAllVariables():
	allGlobalVariables = _ink_player._story.variables_state._global_variables.duplicate(true)		
	allVisitCounts = _ink_player._story.state._visit_counts.duplicate(true)
	
func LoadAllVariables():
	for name in allGlobalVariables.keys():
		if (is_instance_valid([name])):
			_ink_player.set_variable(name,allGlobalVariables[name])
	_ink_player._story.state._visit_counts = allVisitCounts.duplicate(true)

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
	#Global.StoryProgressed.emit()
	
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
	pass
	#Global.StoryProgressed.emit()
	#print("The End")

func OnChoiceMade(choice):
	pass
	prepNewLine()
	#currentStoryText = ""

func OnMakeChoice(index):
	#resetState()
	currentChoiceIndex = index
	#addStateToHistory()

func OnTextCleared():
	if (goBackCached):
		OnGoBack()
	elif (pathJumpCached):
		jumpToPath(pathToJumpTo)
	else:
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
	while _ink_player.can_continue:
		_ink_player.continue_story()
	#Global.StoryProgressed.emit()
	#_ink_player.continue_story_maximally()

func OnGetState():
	savedState = _ink_player.get_state()
	#var a = _ink_player.get_current_path()

func canGoBack():
	if (previousStates.size() > 0):
		return true
	else:
		return false

func OnGoBack():
	var u = ""
	for a in previousStates:
		u += "States. Ind: "+str(previousStates.find(a))+" - Previous:  "+str(a["state"])+" \n"
	Global.DisplayDebugText3.emit(u)
	
	if (previousStates.size() > 0):
		var tmpState = previousStates[previousStates.size()-1].duplicate()
		previousStates.remove_at(previousStates.size()-1)

		#currentStoryText = ""
		goBackCached = false
		prepNewLine()
		resetState()
		_ink_player.choose_path(tmpState["state"])
		_ink_player.continue_story()

		_prompt_choices(tmpState['choices'])
		
		print("Choices: "+str(_ink_player.get_current_choices()))
		#Global.StoryProgressed.emit()
		Global.CommandMade.emit(tmpState["stateName"])
		lastChoiceMade = tmpState["state"]
		#_continued(_ink_player.get_current_text(),null)
	else:
		Global.TextPopup.emit("At the start of time...",commandManagerHandle.commandAreaHandle.global_position + (commandManagerHandle.commandAreaHandle.size / 2))

func jumpToPath(p):
	prepNewLine()
	pathJumpCached = false
	pathToJumpTo = ""
	#lastChoiceMade = _ink_player.get_current_path()
	addStateToHistory(lastChoiceMade)
	resetState(true)
	_ink_player.choose_path(p)
	_ink_player.continue_story()
	#Global.StoryProgressed.emit()

func OnLocationEncountered(loc:String):
	await get_tree().process_frame
	print("ENCOUNTERED RULE: LOCATION")
	if (loc == locationName):
		return
		
	#locationAvailable = true
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
		"NoLocationCommands":
			locationAvailable = false

func addVisitedChoice(c):
	var tmpArr: Array = []
	var p = cachedCurrentPath#_ink_player.current_path.split(".")[0]
	print("ADDING TO VISITED:")
	print(str(p)+" - "+str(c))
	
	if (visistedChoices.has(p)):
		tmpArr = visistedChoices[p].duplicate()
	tmpArr.append(c)
	visistedChoices[p] = tmpArr
	
func hasVisitedBefore(c):
	var p = cachedCurrentPath#_ink_player.current_path.split(".")[0]
	print("Seaching path... current is: "+str(p))
	if (visistedChoices.has(p)):
		for a in visistedChoices[p]:
			if (a.contains(c)):
				return true
	return false
	
func OnCommandMade(com:String):
	lastCommand = currentCommand
	currentCommand = com
	pass

func OnSetSate():
	OnGoBack()
