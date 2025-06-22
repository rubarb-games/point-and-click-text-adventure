extends Control

@export var commandAreaHandle:Control
@export var wordButtonToInstance:PackedScene
@export var storyManagerHandle:StoryManager
@export var textAreaHandle:Node2D

@export var enterCommandHandle:Button

var commandWordButtons:Array
var commandWord:Array
var nounRepresented:bool = false
var verbRepresented:bool = false
var adjectiveRepresented:bool = false

# C0alled when the node enters the scene tree for the first time.
func _ready():
	Global.InventoryInteractibleClicked.connect(OnInventoryInteraction)
	Global.CommandInteractibleClicked.connect(OnCommandInteraction)
	enterCommandHandle.pressed.connect(OnCommandButtonPressed)
	toggleCommandButton(false)

func newCommand():
	for w in range(commandWord.size()):
		if is_instance_valid(commandWord[w]):
			Global.CommandInteractibleClicked.emit(commandWord[w], commandWord[w],false)
	commandWord = []
	#commandWordButtons = []
	toggleCommandButton(false)
	
func executeCommand():
	Global.gamePaused = true
	var tempWord = ""
	for c in commandWord:
		tempWord += c.word.to_lower()
	print("EXECUTING COMMAND: CHecking for word: "+str(tempWord))
	for a in storyManagerHandle.currentChoices:
		print("Checking against: "+str(a))
		
	var i = storyManagerHandle.currentChoices.find(tempWord)
	if (i != -1):
		for b in commandWord:
			b = b as WordButton
			b.moveButtonToLocation(textAreaHandle, false, false)
		await get_tree().create_timer(Global.shortPause).timeout	
		Global.StoryChoiceMade.emit(i)
		var t2:String = ""
		for a in commandWord:
			t2 += a.word + "  "
		Global.CommandMade.emit(t2)
		#for b in button
		#buttonHandle.moveButtonToLocation(tWord)
	else:
		Global.TextPopup.emit("Unkown command..",commandAreaHandle.global_position + (commandAreaHandle.size / 2))
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
	if (commandWord.size() == 3):
		print("COMMANDS: Too many commands!!!!")
		buttonHandle.errorShake()
		Global.TextPopup.emit("Too many words",buttonHandle.global_position + (buttonHandle.size / 2))
		return

	if (buttonHandle.wData.status == WordData.wordStatus.VERB):
		if (verbRepresented):
			print("COMMANDS: Too many verbs!!!")
			buttonHandle.errorShake()
			Global.TextPopup.emit("Too many verbs",buttonHandle.global_position  + (buttonHandle.size / 2))
			return
		else:
			verbRepresented = true

	if (buttonHandle.wData.status == WordData.wordStatus.NOUN):
		if (nounRepresented):
			print("COMMANDS: Too many nouns!!!")
			buttonHandle.errorShake()
			Global.TextPopup.emit("Too many nouns",buttonHandle.global_position + (buttonHandle.size / 2))
			return
		else:
			nounRepresented = true
	
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
	buttonHandle.moveButtonToLocation(tWord)
	
	commandWord.append(tWord)
	#commandWordButtons.append(buttonHandle)
	
	#AUTO COMPLETE COMMANDS IF YOU TAKE OUT "FALSE"
	if commandWord.size() == 2 and false:
#		#Execute command
		executeCommand()
	
	#buttonHandle.queue_free()

func OnCommandButtonPressed():
	executeCommand()

func OnCommandInteraction(word, buttonHandle, eraseEntry):
	if eraseEntry:
		commandWord.erase(buttonHandle)
		#commandWordButtons.erase(buttonHandle)

	if (buttonHandle.wData.status == WordData.wordStatus.VERB):
		verbRepresented = false

	if (buttonHandle.wData.status == WordData.wordStatus.NOUN):
		nounRepresented = false
	
	if (buttonHandle.wData.status == WordData.wordStatus.ADJECTIVE):
		adjectiveRepresented = false
	
	if (commandWord.size() == 0):
		toggleCommandButton(false)
		print("COMMANDS: No commands left")
	#buttonHandle.queue_free()
