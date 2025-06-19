extends Control

@export var inventoryAreaHandle:Control
@export var wordButtonToInstance:PackedScene

var inventoryWords:Array[WordButton]

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.InteractableWordClicked.connect(OnInteractiveButtonClicked)
	Global.CommandInteractibleClicked.connect(OnCommandButtonClicked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func addToInventory(w:WordButton):
	
	var tWordButton:WordButton = wordButtonToInstance.instantiate()
	inventoryAreaHandle.add_child(tWordButton)
	
	tWordButton.updateWordText(w.word)
	tWordButton.updateData(w)
	tWordButton.SetInventory()
	w.moveButtonToLocation(tWordButton)

func OnInteractiveButtonClicked(word, buttonHandle):
	addToInventory(buttonHandle)

func OnCommandButtonClicked(word, buttonHandle, deleteEntry):
	addToInventory(buttonHandle)
