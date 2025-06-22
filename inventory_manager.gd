class_name InventoryManager
extends Control

@export var inventoryAreaHandle:Control
@export var wordButtonToInstance:PackedScene
@export var InventoryLabelHandle:Label

var inventoryWords:Array[WordButton]

var horiSpacing = 120
var vertiSpacing = 60
var zigZagSpace = 20
var rowNum = 8
var margin = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.InteractableWordClicked.connect(OnInteractiveButtonClicked)
	Global.CommandInteractibleClicked.connect(OnCommandButtonClicked)
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
	
	pos.x = margin + (ind * horiSpacing)
	pos.y = vertiSpacing * (round(ind/ rowNum)) + (zigZagSpace * (ind % 2))
	
	return pos

func updateInventoryLayout():
	var c = inventoryAreaHandle.get_children()
	
	var targetPosition:Array[Vector2] = []
	targetPosition.resize(c.size())
	
	for a in range(c.size()):
		targetPosition[a].x = margin + (horiSpacing * a)
		targetPosition[a].y = vertiSpacing * (round(a / rowNum)) + (zigZagSpace * (a % 2))
		
		var s = SimonTween.new()
		s.createTween(c[a],"position",targetPosition[a] - c[a].position,Global.shortPause)

func OnInteractiveButtonClicked(word, buttonHandle):
	addToInventory(buttonHandle,false)

func OnCommandButtonClicked(word, buttonHandle, deleteEntry):
	addToInventory(buttonHandle, true)
