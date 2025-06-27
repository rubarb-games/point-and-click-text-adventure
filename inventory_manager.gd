class_name InventoryManager
extends Control

@export var inventoryAreaHandle:Control
@export var wordButtonToInstance:PackedScene
@export var InventoryLabelHandle:Label
@export var storyManagerHandle:StoryManager

var inventoryWords:Array[WordButton]

var horiSpacing = 100
var vertiSpacing = 40
var zigZagSpace = 6
var rowNum = 8
var margin = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.InteractableWordClicked.connect(OnInteractiveButtonClicked)
	Global.CommandInteractibleClicked.connect(OnCommandButtonClicked)
	Global.StoryProgressed.connect(OnStoryProgressed)
	InventoryLabelHandle.modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func addToInventory(w:WordButton, deleteAtEnd:bool):
	
	if (InventoryLabelHandle.modulate.a == 0):
		var s = SimonTween.new()
		s.createTween(InventoryLabelHandle,"modulate:a",1,Global.shortPause)
	
	var tWordButton:WordButton = wordButtonToInstance.instantiate()
	inventoryAreaHandle.add_child(tWordButton)
	
	tWordButton.updateWordText(w.word)
	tWordButton.updateData(w)
	tWordButton.SetInventory()
	tWordButton.toggleDrifting(true)
	tWordButton.position = setInventoryPosition(tWordButton.get_index())
	w.moveButtonToLocation(tWordButton,deleteAtEnd)
	updateInventoryLayout()

func setInventoryPosition(ind):
	var pos:Vector2
	
	pos.x = (margin + (ind * horiSpacing)) % (margin + (horiSpacing*rowNum))
	pos.y = vertiSpacing * (round(ind/ rowNum)) + (zigZagSpace * (ind % 2))
	
	return pos

func updateInventoryLayout():
	var c = inventoryAreaHandle.get_children()
	
	var targetPosition:Array[Vector2] = []
	targetPosition.resize(c.size())
	
	for a in range(c.size()):
		targetPosition[a].x = margin + (horiSpacing * a) % (margin + (horiSpacing*(rowNum-1)))
		targetPosition[a].y = vertiSpacing * (round(a / rowNum)) + (zigZagSpace * (a % 2))
		
		var s = SimonTween.new()
		s.createTween(c[a],"position",targetPosition[a] - c[a].position,Global.shortPause)
	
	checkIfWordIsUseful()

func OnStoryProgressed():
	updateInventoryLayout()

func checkIfWordIsUseful():
	await get_tree().process_frame
	#print("CHECKINg THIS STUFF OUTTTT")
	var skip:bool = false
	for i in inventoryAreaHandle.get_children():
		skip = false
		i.setMutedColor()
		if (i.word == "back" and !skip):
			i.setSpecialColor()
			skip = true
			
		#print("CHECKING FOR MATCHES FOR... "+str(i.word))
		for s in storyManagerHandle.currentChoices:
			#print("CHECKING "+str(i.word)+" AGAINST: "+str(s))
			if (s.contains(i.word.strip_edges()) and !skip):
				#print("FOUND MATCH IN WORD! "+str(i.word)+" AND "+str(s))
				i.setHighlightedColor()
				skip = true
		
		if (storyManagerHandle.hasVisitedBefore(i.word)):
			pass
			print("WORD: "+str(i.word)+" HAS BEEN USED BEFORE!")
		else:
			pass #not used before

func OnInteractiveButtonClicked(word, buttonHandle):
	addToInventory(buttonHandle,false)

func OnCommandButtonClicked(word, buttonHandle, deleteEntry):
	for i in inventoryAreaHandle.get_children():
		if i.word == buttonHandle.word:
			buttonHandle.moveButtonToLocation(i,true)
			i.enable()
	#addToInventory(buttonHandle, true)
