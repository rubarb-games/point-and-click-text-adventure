extends Control

var currentString:String = ""
@export var wordButtonToInstance:PackedScene
@export var textAreaHandle:Control

#
# TEMP VARIABLES
#

var tempString:String = "The _Door[noun is creaking at the other end of the room. One might _walk[verb over, maybe. Or just stand and _look[verb at it"

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.InteractableWordClicked.connect(OnInteractiveButtonClicked)
	
	processText()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func fetchText():
	currentString = tempString
	
func processText():
	fetchText()
	#print("FETCHED! "+currentString)
	var wordsRaw:Array = currentString.split(" ")
	var words:Array[WordData] = []
	var tWord:WordData
	var tw
	
	for w in wordsRaw:
		#print("Processing word "+str(w))
		tWord = WordData.new()
		if (w[0] == "_"):
			w.lstrip("_")
			tw = w.split("[")
			match tw[1]:
				"noun":
					print("YEP! NOUN!")
					tWord.status = WordData.wordStatus.NOUN
				"verb":
					print("YEP! VERB!")
					tWord.status = WordData.wordStatus.VERB
			tWord.isDiscoverable = true
			w = tw[0]
		
		tWord.word = w
		words.append(tWord)
	
	var s:String = ""
	var butt:WordButton
	
	for b in words:
		#print("Instantiating")
		butt = wordButtonToInstance.instantiate()
		textAreaHandle.add_child(butt)
		butt.word = b.word
		butt.wData = b
		if (b.isDiscoverable):
			butt.SetInteractible()
			butt.updateWord()
		else:
			butt.updateWord()

func OnInteractiveButtonClicked(word, buttonHandle):
	pass
	#buttonHandle.queue_free()
