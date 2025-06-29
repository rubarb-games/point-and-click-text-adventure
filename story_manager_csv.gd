class_name StoryManager
extends Control

var story_data:Dictionary = {}
@export var csvPathResource:Translation
@export var csvPath:String

@export var centerTextMarkerHandle:Control

var void_id:String = "void"

var currentChoices:Dictionary = {}
var currentRules:Dictionary = {}
var currentID:String
var currentText:String

var cacheGoBack:bool = false
var cachedChoice:String = ""

var genericChoicesAvailable:bool = false
var genericChoices:Dictionary = {}

var locationChoicesAvailable:bool = false
var locationID:String = ""
var locationChoices:Dictionary = {}

var undoQueue:Array[Dictionary] = []
var visited_ids:Dictionary = {}

var specialChoices:Dictionary = {}
var cachedLocationChoices:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.StoryChoiceMade.connect(OnMakeChoice)
	Global.StoryTextCleared.connect(OnTextCleared)
	Global.LocationEncountered.connect(OnLocationEncountered)
	Global.RuleEncountered.connect(OnRuleEncountered)
	Global.GoBack.connect(OnGoBack)
	Global.StoryVariableEncountered.connect(OnSetStoryVariable)
	
	await load_csv(csvPath)
	addSpecialCommands()
	await get_tree().process_frame
	show_node("tutorial_start_1")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_csv(path:String):
	
	print("Loading file at: "+path)
	
	var file = FileAccess.open(path, FileAccess.READ)
	var lines = file.get_as_text().split("\n")
	var header = lines[0].split(",")
	print(header)
	
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		if line == "":
			continue
		print(line)
		var cells = line.split(",",false)
		var row = {}
		for j in range(min(cells.size(),header.size())):
			row[header[j]] = cells[j]
			
		var id = row.get("ID","unnamed")
		row["Choices"] = parse_choices(row.get("Choices", ""))
		row["Rules"] = parse_rules(row.get("Rules",""))
		story_data[id] = row
	return

func parse_choices(choices_str:String) -> Dictionary:
	var choices = {}
	print("Choices string: "+choices_str)
	for entry in choices_str.split(";"):
		var parts = entry.strip_edges().split("=")
		if (parts.size()==2):
			choices[parts[0].strip_edges()] = parts[1].strip_edges()
	return choices
	
func parse_rules(rules_str:String) -> Dictionary:
	var rules:Dictionary = {}
	
	for entry in rules_str.strip_edges().split(";"):
		var parts = entry.strip_edges().split("=")
		var result:Dictionary = {}
		if (parts.size() == 2):
			if (parts[1].contains(":")):
				var subPart:Array = parts[1].split(":")
				result["name"] = subPart[0]
				result["value"] = subPart[1]
			else:
				result["name"] = parts[1].strip_edges()
			rules[parts[0].strip_edges()] = result
	return rules

func fetch_viable_choices(choicesDict:Dictionary):
	var resultChoices = {}
	print("Processing choices at ID \""+str(currentID)+"\" now...")
	for c in choicesDict.keys():
		print(c+" - "+str(choicesDict[c]))
		var viableChoice = true
		var choiceData = get_node_data(choicesDict[c])
		print(choiceData)
		if (!choiceData):
			continue
		
		for r in choiceData["Rules"].keys():
			if (r=="requiredVar"):
				var v = choiceData["Rules"][r]
				var u = Global.getStoryVar(v["name"])
				if (!u):
					print("Choice removed. Variable \""+str(v["name"])+"\" has not been assigned")
					viableChoice = false
				elif (u != v["value"]):
					print("Choice removed. Player does not possess variable \""+str(v["name"])+"\" at value: "+str(v["value"]))
					viableChoice = false
		if (viableChoice):
			resultChoices[c] = choicesDict[c]
		elif (choiceData["Rules"].has("fallbackID")):
			print("Fallback: Adding fallback ID instead at \""+str(choiceData["Rules"]["fallbackID"])+"\"")
			resultChoices[c] = choiceData["Rules"]["fallbackID"]["name"]
	return resultChoices
	
func show_node(id:String):
	var node_id = get_node_data(id)
	if (node_id):
		store_visited_id(false)
		currentText = node_id["Text"]
		currentID = node_id["ID"]
		print("ID: "+node_id["ID"]+" - TEXT:"+node_id["Text"])
		print("CHOICES:")
		for label in node_id["Choices"].keys():
			print(" - ", label, "=>", node_id["Choices"][label])
		var tempChoices = node_id["Choices"].duplicate()
		currentChoices = fetch_viable_choices(tempChoices)
				
		print("Choices are now processed")
		currentRules = node_id["Rules"].duplicate()
		
		Global.StoryProgressed.emit()
		Global.CommandMade.emit(node_id["Title"])

func get_node_data(id:String):
	var node = story_data.get(id)
	if node:
		return node
	return null

func current_node_has_choice(choice:String):
	node_has_choice(choice,currentID)

func node_has_choice(choice:String, storyNode:String):
	if (story_data.has(storyNode)):
		var data = story_data[storyNode]
		if (data.has(choice)):
			return true
	return false

func make_choice(choice_id:String):
	store_visited_id(true,choice_id)
	resetCache()
	if (story_data.has(choice_id)):
		show_node(choice_id)
	else:
		show_node(void_id)
		print("WARNING: Tried accessing an ID that led nowhere ("+str(choice_id)+")")

func store_visited_id(addToUndoQueue:bool = true,overrideID:String = ""):
	var tmpID = currentID
	if (overrideID != ""):
		tmpID = overrideID
	
	if (addToUndoQueue and !currentID.contains("hint")):
		if (!visited_ids.has(tmpID)):
			Global.TextPopup.emit("New text discovered",centerTextMarkerHandle.global_position)
		var tmpUndo = {
			"ID": currentID,
			"locChoices":locationChoices,
			"locID":locationID
		}
		undoQueue.append(tmpUndo)
		
	visited_ids[tmpID] = true

func has_visited(id:String):
	if (visited_ids.has(id)):
		return true
	return false

func can_go_back():
	if (undoQueue.size() > 0):
		return true
	else:
		return false

func go_back():	
	if (can_go_back()):
		cacheGoBack = false
		var gotoID:Dictionary = undoQueue.pop_back()
		Global.TextPopup.emit("You go back...",centerTextMarkerHandle.global_position)
		#Update location to previous spot
		locationChoices = gotoID["locChoices"]
		locationID = gotoID["locID"]
		show_node(gotoID["ID"])

func OnGoBack():
	cacheGoBack = true
	#go_back()

func OnMakeChoice(id:String,type:String):
	match type:
		"normal":
			cachedChoice = currentChoices[id]
		"location":
			cachedChoice = locationChoices[id]
		"generic":
			cachedChoice = genericChoices[id]
		"hint":
			cachedChoice = "hint_a"
		"back":
			cacheGoBack = true
	
	Global.DumpText.emit(true)

func OnTextCleared():
	if (cacheGoBack):
		go_back()
	else:
		make_choice(cachedChoice)

func resetCache():
	cacheGoBack = false
	cachedChoice = ""

func addSpecialCommands():
	specialChoices["back"] = "back"

func get_all_choices(includeLocations:bool = true):
	var allChoiceDict:Dictionary = {}
	allChoiceDict = currentChoices.duplicate()
	var tmpLocationChoices = locationChoices.duplicate()
	var tmpGenericChoices = genericChoices.duplicate()
	var tmpSpecialChoices = specialChoices.duplicate()
	
	if (locationChoicesAvailable):
		allChoiceDict.merge(tmpLocationChoices)
	if (genericChoicesAvailable):
		allChoiceDict.merge(tmpGenericChoices)
	#allChoiceDict.merge(tmpSpecialChoices)
	
	return allChoiceDict

func OnRuleEncountered(rule:String):
	match rule:
		"ClearHistory":
			print("RULE: CLEARING HISTORY!")
			undoQueue = []
		"Generic":
			print("RULE! ADDING GENERIC COMMANDS!")
			genericChoices = currentChoices.duplicate()
			genericChoicesAvailable = true
		"NoLocationCommands":
			print("RULE! REMOVING LOCATION COMMANDS")
			locationChoicesAvailable = false
		#"SetVariable":
			

func OnSetStoryVariable():	
	pass

func loc_available():
	return locationChoicesAvailable

func OnLocationEncountered(location:String):
	print("RULE! ADDING LOCATION CHOICES")
	locationChoicesAvailable = true
	if (locationID == location):
		return
		
	var tmpLocData:Dictionary = get_node_data(currentID)
	if tmpLocData:
		locationID = location
		var tmpChoices = tmpLocData["Choices"].duplicate()
		locationChoices = fetch_viable_choices(tmpChoices)
	else:
		locationChoicesAvailable = false
