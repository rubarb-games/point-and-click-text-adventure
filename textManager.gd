extends Control

var currentString:String = ""
@export var wordButtonToInstance:PackedScene
@export var textAreaHandle:Node2D
@export var textAreaGuide:Control

@export var InventoryManagerHandle:InventoryManager
@export var storyManagerHandle:StoryManager
@export var lastCommandText:RichTextLabel
var words:Array[WordData]
var wordButtons:Array[WordButton]

var textAreaPosition:Vector2
#
# TEMP VARIABLES
#

var tempString:String = "The _Door[noun is creaking at the other end of the room. One might _walk[verb over, maybe. Or just stand and _look[verb at it"

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.InteractableWordClicked.connect(OnInteractiveButtonClicked)
	Global.StoryProgressed.connect(OnStoryProgressed)
	Global.StoryChoiceMade.connect(OnStoryChoiceMade)
	Global.CommandMade.connect(OnCommandMade)
	#processText()
	textAreaPosition = textAreaHandle.global_position
	#lastCommandText.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func evaluateText():
	currentString = storyManagerHandle.currentStoryText
	instantlyKillAllText()
	Global.DisplayDebugText.emit("IN TEXT MANAGERRRR!")
	#If this is text to be displayed, indicated by the arrow "^"
	if (currentString[0] == "."):
		currentString = currentString.substr(1)
		processText()

func dumpText():
	for w in range(wordButtons.size()):
		if (is_instance_valid(wordButtons[w])):
			wordButtons[w].Die()
	wordButtons = []
	await get_tree().create_timer(0.5).timeout
	Global.StoryTextCleared.emit()
	
func instantlyKillAllText():
	var allTextKids = textAreaHandle.get_children()
	for tx in range(allTextKids.size()):
		allTextKids[tx].queue_free()
	
func fetchText():
	currentString = tempString
	
func processText():
	#print("FETCHED! "+currentString)
	var wordsRaw:Array = currentString.split(" ")
	var words:Array[WordData] = []
	var tWord:WordData
	var tw
	words = []
	
	for w in wordsRaw:
		#print("Processing word "+str(w))
		tWord = WordData.new()
		if (w[0] == "["):
			w = w.substr(1)
			tw = w.split("]")
			match tw[0]:
				"noun":
					print("YEP! NOUN!")
					tWord.status = WordData.wordStatus.NOUN
				"verb":
					print("YEP! VERB!")
					tWord.status = WordData.wordStatus.VERB
			tWord.isDiscoverable = true
			w = tw[1]
		
		tWord.word = w
		words.append(tWord)
	
	var s:String = ""
	var butt:WordButton
	
	for b in words:
		#print("Instantiating")
		butt = wordButtonToInstance.instantiate()
		textAreaHandle.add_child(butt)
		#butt.word = b.word
		butt.updateWordText(b.word)
		butt.wData = b
		wordButtons.append(butt)
		if (b.isDiscoverable):
			if (!checkIfWordIsDiscovered(b.word)):
				butt.SetInteractible()
				butt.toggleDrifting(true)
				butt.updateWord()
				butt.fadeIn()
		else:
			butt.updateWord()
			butt.fadeIn()
	
	updateLayout()

func checkIfWordIsDiscovered(w:String):
	print("CHECKING WORDS!")
	var wordButtons:Array = InventoryManagerHandle.inventoryAreaHandle.get_children() as Array[WordButton]
	
	for item in wordButtons:
		print("Item == "+str(item.word))
		if (item.word == w):
			return true
	return false

func updateLayout():
	textAreaHandle.global_position = textAreaPosition
	var allWords = textAreaHandle.get_children()
	
	var idealHoriOffset = 120
	var lineStart = textAreaGuide.global_position + textAreaGuide.size / 2
	var idealLineWidth = textAreaGuide.size.x / 2 - idealHoriOffset
	var currentCaret:Vector2 = Vector2(0,0) - Vector2(idealLineWidth/2,0)
	var idealHoriSpacing = 12
	var idealVertiSpacing = 40
	currentCaret[0] -= idealLineWidth / 2
	
	var tSize
	print("Caret is: "+str(currentCaret))
	print("--------------")
	for word in allWords:
		word = word as WordButton
		word.global_position = currentCaret + lineStart
		print("Word is: "+str(word.word)+" and the pos is: "+str(word.global_position))
		tSize = word.size
		currentCaret[0] += tSize[0] + idealHoriSpacing
		if (currentCaret[0] > idealLineWidth):
			currentCaret[0] = - idealLineWidth
			currentCaret[1] += idealVertiSpacing
		

func OnStoryProgressed():
	evaluateText()

func OnStoryChoiceMade(i):
	dumpText()


func OnCommandMade(w):
	var s = SimonTween.new()
	await s.createTween(lastCommandText,"modulate:a",-1,Global.veryShortPause).tweenDone
	lastCommandText.modulate.a = 0
	lastCommandText.text = w.replace("_"," ")
	s.createTween(lastCommandText,"modulate:a",1,Global.longPause)

func OnInteractiveButtonClicked(word, buttonHandle):
	pass
	#buttonHandle.queue_free()
