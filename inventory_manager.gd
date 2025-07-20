class_name InventoryManager
extends Control

@export var inventoryAreaHandle:Control
@export var wordButtonToInstance:PackedScene
@export var InventoryLabelHandle:Label
@export var storyManagerHandle:StoryManager

var inventoryWords:Array[WordButton]

var horiSpacing = 80
var vertiSpacing = 40
var zigZagSpace = 24
var rowNum = 10
var margin = 40

var rowScaleTreshold = 1
var targetScale = 1
var scaleDampingFactor = 0.045

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
	#tWordButton.position = setInventoryPosition(tWordButton.get_index())
	tWordButton.global_position = w.global_position
	w.moveButtonToLocation(tWordButton,deleteAtEnd)
	updateInventoryLayout()

func setInventoryPosition(ind):
	var pos:Vector2
	
	pos.x = (margin + (ind * horiSpacing)) % (margin + (horiSpacing*rowNum))
	pos.y = vertiSpacing * (round(ind/ rowNum)) + (zigZagSpace * (ind % 2))
	
	return pos

func updateInventoryLayout():
	var c = inventoryAreaHandle.get_children()

	var heightTreshold = rowScaleTreshold * vertiSpacing
	var currentHeight = round(c.size() / rowNum) * vertiSpacing
	var currentWidth:float = margin + (horiSpacing * rowNum)
	
	if (currentHeight != 0):
		var scaleFactor:float = clamp((float(heightTreshold)/float(currentHeight)),0.01,1.0)
		#print_rich("[color=CRIMSON] "+str(currentHeight)+" / "+str(heightTreshold)+" = "+str(scaleFactor)+" hell yeah. Also, general size: "+str(inventoryAreaHandle.size.x)+"[/color]")
		var dampingFactor = scaleDampingFactor
		scaleFactor = lerp(1.0,scaleFactor,dampingFactor)
		if (scaleFactor != targetScale):
			targetScale = scaleFactor
			var tmpScl = Vector2(scaleFactor,scaleFactor)
			var s = SimonTween.new()
			#print_rich("[color=GREEN]AYYY Scale is :"+str(inventoryAreaHandle.scale.x)+" / "+str((inventoryAreaHandle.scale.x * tmpScl.x))+" = "+str((inventoryAreaHandle.scale.x - tmpScl.x)*currentWidth/2))
			s.createTween(inventoryAreaHandle,"scale",(Vector2.ONE-tmpScl)*-1,Global.shortPause).anotherParallel().\
			#createTween(inventoryAreaHandle,"position:y",-vertiSpacing/2,Global.shortPause).anotherParallel().\
			createTween(inventoryAreaHandle,"position:x",((inventoryAreaHandle.scale.x - (inventoryAreaHandle.scale.x * tmpScl.x)) * currentWidth) / 2.0,Global.shortPause)
			
			#inventoryAreaHandle.scale = Vector2(scaleFactor,scaleFactor)
	
	var targetPosition:Array[Vector2] = []
	targetPosition.resize(c.size())
	
	for a in range(c.size()):
		targetPosition[a].x = margin + ((horiSpacing * (a+1)) % ( (horiSpacing*(rowNum)))) - (c[a].size.x / 2)
		targetPosition[a].y = vertiSpacing * (ceil((a+1) / (rowNum))) + (zigZagSpace * (a % 2))
		
		var s = SimonTween.new()
		s.createTween(c[a],"position",targetPosition[a] - c[a].position,Global.shortPause)
		#c[a].position = targetPosition[a]
	
	checkIfWordIsUseful()

#func moveWordToPosition

func OnStoryProgressed():
	updateInventoryLayout()

func checkIfWordIsUseful():
	await get_tree().process_frame
	#print("CHECKINg THIS STUFF OUTTTT")
	var skip:bool = false
	var undiscoveredAction:bool = false
	for i in inventoryAreaHandle.get_children():
		skip = false
		undiscoveredAction = false
		i.setMutedColor()
		if ((i.word == "back" or i.word == "hint") and !skip):
			i.setSpecialColor()
			skip = true
			
		var choices = storyManagerHandle.get_all_choices(true)
		var choicesNoLocations = storyManagerHandle.get_all_choices(false)
		for s in choices.keys():
			if (s.contains(i.word.strip_edges())):
				if (!skip):
					#print_rich("[color=AQUA]YEAH LETS SEE!!!!"+str(s)+"[/color]")
					if (partiallyContains(i.word.strip_edges(),choicesNoLocations)):
						i.setHighlightedColor()
					else:
						i.setSemiMutedColor()
					#i.setHighlightedColor()
					skip = true
		
				if (!storyManagerHandle.has_visited(choices[s])):
					#print("HAS NOT VISITED: "+str(s))
					undiscoveredAction = true
					
		if (undiscoveredAction):
			i.setUndiscoveredOptions()
		else:
			i.setDiscoveredOptions()
	
func partiallyContains(s:String,d:Dictionary):
	for a in d.keys():
		if (a.contains(s)):
			return true
	return false

func OnInteractiveButtonClicked(word, buttonHandle):
	addToInventory(buttonHandle,false)

func OnCommandButtonClicked(word, buttonHandle, deleteEntry):
	for i in inventoryAreaHandle.get_children():
		if i.word == buttonHandle.word:
			buttonHandle.moveButtonToLocation(i,true)
			i.enable()
