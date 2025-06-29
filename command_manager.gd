extends Control

@export var commandAreaHandle:Control
@export var wordButtonToInstance:PackedScene
@export var storyManagerHandle:StoryManager
@export var textAreaHandle:Node2D
@export var textMarkerHandle:Control

@export var enterCommandHandle:Button
@export var centerCommandMarkerHandle:Control

@export var smallWordHandle:WordButton

var commandWordButtons:Array
var commandWord:Array
var nounRepresented:bool = false
var verbRepresented:bool = false
var adjectiveRepresented:bool = false

var currentVerb:WordButton
var currentNoun:WordButton
var horiSpacing = 15
var margin = 60

# C0alled when the node enters the scene tree for the first time.
func _ready():
	Global.InventoryInteractibleClicked.connect(OnInventoryInteraction)
	Global.CommandInteractibleClicked.connect(OnCommandInteraction)
	Global.CommandMade.connect(OnCommandMade)
	enterCommandHandle.pressed.connect(OnCommandButtonPressed)
	toggleCommandButton(false)
	smallWordHandle.updateWordText("")

func newCommand():
	for w in range(commandWord.size()):
		if is_instance_valid(commandWord[w]):
			Global.CommandInteractibleClicked.emit(commandWord[w], commandWord[w],false)
	commandWord = []
	smallWordHandle.updateWordText("")
	nounRepresented = false
	verbRepresented = false
	#commandWordButtons = []
	toggleCommandButton(false)
	
func executeCommand():
	Global.gamePaused = true
	var tempWord = ""
	var commandFound:bool = false
	#for c in commandWord:
	#	tempWord += c.word.to_lower()
	#print("EXECUTING COMMAND: CHecking for word: "+str(tempWord))
	if (verbRepresented):
		tempWord += currentVerb.word.to_lower()
	if (nounRepresented):
		tempWord += "_" + smallWordHandle.word.to_lower() + "_" + currentNoun.word.to_lower()
		
	print("TEMPWORD IS: "+str(tempWord))
	#var availableChoices = storyManagerHandle.get_all_choices(true)
	var i = storyManagerHandle.currentChoices.has(tempWord)
	if (i):
		commandFound = true
		Global.StoryPartialProgressed.emit(tempWord,"normal")
		#storyManagerHandle.addVisitedChoice(tempWord)
		for b in commandWord:
			b = b as WordButton
			b.moveButtonToLocation(textMarkerHandle, false, false)
		var s = SimonTween.new()
		s.createTween(smallWordHandle,"modulate:a",-1,Global.veryShortPause)
		#Global.CommandMade.emit(tempWord)
		#await get_tree().create_timer(Global.shortPause).timeout	
		Global.StoryChoiceMade.emit(tempWord,"normal")
		#for b in button
		#buttonHandle.moveButtonToLocation(tWord)
	elif (tempWord == "__back" or tempWord == "take__back"):
		if (storyManagerHandle.can_go_back()):
			commandFound = true
			#storyManagerHandle.goBackCached = true
			#Global.CommandMade.emit("going back")
			Global.StoryPartialProgressed.emit(tempWord,"back")
			Global.StoryChoiceMade.emit(tempWord,"back")
		else:
			Global.ErrorPopup.emit()
			Global.TextPopup.emit("At the start of time...",centerCommandMarkerHandle.global_position)#+ (commandAreaHandle.size / 2))
	else:
		print("TESTING SECONDARY CHOICES")
		if storyManagerHandle.locationChoices.has(tempWord) and storyManagerHandle.locationChoicesAvailable and !commandFound:
			commandFound = true
			Global.StoryPartialProgressed.emit(tempWord,"back")
			Global.StoryChoiceMade.emit(tempWord,"location")
			#Global.CommandMade.emit(tempWord)
		if storyManagerHandle.genericChoices.has(tempWord) and storyManagerHandle.genericChoicesAvailable and !commandFound:
			commandFound = true
			Global.StoryPartialProgressed.emit(tempWord,"back")
			Global.StoryChoiceMade.emit(tempWord,"generic")
			#Global.CommandMade.emit(tempWord)
			
		if (!commandFound):
			Global.ErrorPopup.emit()
			Global.TextPopup.emit("Unkown command..",centerCommandMarkerHandle.global_position)# + (commandAreaHandle.size / 2))
			for d in commandWord:
				d.shake()
			await get_tree().create_timer(0.4).timeout	
	
	Global.gamePaused = false
	newCommand()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func toggleCommandButton(vis:bool = true):
	var s = SimonTween.new()
	if (vis):
		enterCommandHandle.modulate.a = 0
		await s.createTween(enterCommandHandle,"modulate:a",1,0.2).tweenDone
		enterCommandHandle.modulate.a = 1
	else:
		enterCommandHandle.modulate.a = 1
		await s.createTween(enterCommandHandle,"modulate:a",-1,0.2).tweenDone
		enterCommandHandle.modulate.a = 0
		
func OnInventoryInteraction(word, buttonHandle):
	var isCurrentlyVerb = false
	var isCurrentlyNoun = false
	
	if (commandWord.size() == 3):
		print("COMMANDS: Too many commands!!!!")
		buttonHandle.errorShake()
		Global.ErrorPopup.emit()
		Global.TextPopup.emit("Too many words",buttonHandle.global_position + (buttonHandle.size / 2))
		return

	if (buttonHandle.wData.status == WordData.wordStatus.VERB):
		if (verbRepresented):
			print("COMMANDS: Too many verbs!!!")
			buttonHandle.errorShake()
			Global.ErrorPopup.emit()
			Global.TextPopup.emit("Too many verbs",buttonHandle.global_position  + (buttonHandle.size / 2))
			return
		else:
			isCurrentlyVerb = true

	if (buttonHandle.wData.status == WordData.wordStatus.NOUN):
		if (nounRepresented):
			print("COMMANDS: Too many nouns!!!")
			buttonHandle.errorShake()
			Global.ErrorPopup.emit()
			Global.TextPopup.emit("Too many nouns",buttonHandle.global_position + (buttonHandle.size / 2))
			return
		else:
			isCurrentlyNoun = true

	
	if (buttonHandle.wData.status == WordData.wordStatus.ADJECTIVE):
		if (adjectiveRepresented):
			print("COMMANDS: Too many adjectives")
			buttonHandle.errorShake()
			return
		else:
			adjectiveRepresented = true
	
	if (commandWord.size() == 0):
		toggleCommandButton(true)		
	
	var tWord = wordButtonToInstance.instantiate()
	commandAreaHandle.add_child(tWord)
	
	tWord.updateWordText(buttonHandle.word)
	tWord.updateData(buttonHandle)
	tWord.SetCommands()
	#buttonHandle.disable()
	buttonHandle.disable()
	#buttonHandle.moveButtonToLocation(tWord)
	
	commandWord.append(tWord)
	
	if (isCurrentlyVerb):
		verbRepresented = true
		currentVerb = tWord
		
	if (isCurrentlyNoun):
		nounRepresented = true
		currentNoun = tWord
	#commandWordButtons.append(buttonHandle)
	
	updateLayout()
	
	#AUTO COMPLETE COMMANDS IF YOU TAKE OUT "FALSE"
	if commandWord.size() == 2 and false:
#		#Execute command
		executeCommand()
	
	#buttonHandle.queue_free()

func updateLayout():
	
	var nounTargetPos:Vector2
	var fadeOutMiniWord:bool = false
	if (is_instance_valid(currentVerb)):
		chooseSmallWord()
		currentVerb.position.x = margin
		#verbTargetPos.x = margin
		#var s = SimonTween.new()
		#s.createTween(currentVerb,"position",verbTargetPos - currentVerb.position,Global.shortPause)
	else:
		fadeOutMiniWord = true
	if (is_instance_valid(currentNoun)):
		if (verbRepresented):
			smallWordHandle.position.x = currentVerb.position.x + currentVerb.size.x + horiSpacing
			smallWordHandle.modulate.a = 0
			var s = SimonTween.new()
			s.createTween(smallWordHandle,"modulate:a",1,Global.shortPause)
			nounTargetPos.x = smallWordHandle.position.x + smallWordHandle.size.x + horiSpacing
			var k = SimonTween.new()
			k.createTween(currentNoun,"position",nounTargetPos - currentNoun.position,Global.shortPause)
		else:
			nounTargetPos.x = margin
			fadeOutMiniWord = true
	else:
			fadeOutMiniWord = true
	if (fadeOutMiniWord):
		var s = SimonTween.new()
		s.createTween(smallWordHandle,"modulate:a",-1,Global.shortPause)
			
			
func chooseSmallWord():
	if (!verbRepresented):
		return
		
	match currentVerb.word:
		"look":
			smallWordHandle.updateWordText("at")
		"walk":
			smallWordHandle.updateWordText("to")
		_:
			smallWordHandle.updateWordText("")

func OnCommandButtonPressed():
	Global.spriteIrisPopup.emit(centerCommandMarkerHandle.global_position)#commandAreaHandle.global_position+(commandAreaHandle.size/2))
	executeCommand()

func OnCommandInteraction(word, buttonHandle, eraseEntry):
	if eraseEntry:
		commandWord.erase(buttonHandle)
		#commandWordButtons.erase(buttonHandle)

	if (buttonHandle.wData.status == WordData.wordStatus.VERB):
		verbRepresented = false
		currentVerb = null

	if (buttonHandle.wData.status == WordData.wordStatus.NOUN):
		nounRepresented = false
		currentNoun = null
	
	if (buttonHandle.wData.status == WordData.wordStatus.ADJECTIVE):
		adjectiveRepresented = false
	
	updateLayout()
	
	if (commandWord.size() == 0):
		toggleCommandButton(false)
		print("COMMANDS: No commands left")
	#buttonHandle.queue_free()

func OnCommandMade(word):
	pass
