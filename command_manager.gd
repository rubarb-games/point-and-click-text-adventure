extends Control

@export var commandAreaHandle:Control
@export var wordButtonToInstance:PackedScene

var commandWord:Array
var nounRepresented:bool = false
var verbRepresented:bool = false

# C0alled when the node enters the scene tree for the first time.
func _ready():
	Global.InventoryInteractibleClicked.connect(OnInventoryInteraction)
	Global.CommandInteractibleClicked.connect(OnCommandInteraction)

func newCommand():
	for w in range(commandWord.size()):
		if is_instance_valid(commandWord[w]):
			Global.CommandInteractibleClicked.emit(commandWord[w].word, commandWord[w],false)
	commandWord = []
	
func executeCommand():
	Global.gamePaused = true
	await get_tree().create_timer(0.5).timeout
	Global.gamePaused = false
	newCommand()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func OnInventoryInteraction(word, buttonHandle):
	if (commandWord.size() == 2):
		print("COMMANDS: Too many commands!!!!")
		return

	if (buttonHandle.wData.status == WordData.wordStatus.VERB):
		if (verbRepresented):
			print("COMMANDS: Too many verbs!!!")
			return
		else:
			verbRepresented = true

	if (buttonHandle.wData.status == WordData.wordStatus.NOUN):
		if (nounRepresented):
			print("COMMANDS: Too many nouns!!!")
			return
		else:
			nounRepresented = true
			
	
	var tWord = wordButtonToInstance.instantiate()
	commandAreaHandle.add_child(tWord)
	
	tWord.updateWordText(buttonHandle.word)
	tWord.updateData(buttonHandle)
	tWord.SetCommands()
	buttonHandle.moveButtonToLocation(tWord)
	
	commandWord.append(tWord)
	if commandWord.size() == 2:
#		#Execute command
		executeCommand()
	
	#buttonHandle.queue_free()

func OnCommandInteraction(word, buttonHandle, eraseEntry):
	if eraseEntry:
		commandWord.erase(buttonHandle)

	if (buttonHandle.wData.status == WordData.wordStatus.VERB):
		verbRepresented = false

	if (buttonHandle.wData.status == WordData.wordStatus.NOUN):
		nounRepresented = false
	
	if (commandWord.size() == 0):
		print("COMMANDS: No commands left")
	#buttonHandle.queue_free()
