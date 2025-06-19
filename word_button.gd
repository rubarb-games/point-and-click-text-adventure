class_name WordButton
extends Control

enum buttonStatus { TEXTLOG_NORMAL, TEXTLOG_INTERACTIBLE, INVENTORY, COMMAND, DISABLED }
var bS:buttonStatus

@export var buttonHandle:RichTextLabel
@export var interactableColor:Color = Color.DARK_KHAKI
@export var fadeCurve:Curve

var wData:WordData

var word:String = ""
var discoverable:bool = false
var inventoryItem:bool = false
var commandItem:bool = false

var active:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateWord(isDiscoverable:bool = false):
	buttonHandle.text = word


func updateWordText(w:String):
	word = w
	self.text = w

func updateData(button:WordButton):
	word = button.word
	wData = button.wData

func disable():
	buttonHandle.self_modulate = Color.WHITE
	active = false

func SetInteractible():
	bS = buttonStatus.TEXTLOG_INTERACTIBLE
	buttonHandle.self_modulate = interactableColor

func SetInventory():
	bS = buttonStatus.INVENTORY
	buttonHandle.self_modulate = Color.WHITE

func SetCommands():
	bS = buttonStatus.COMMAND

func SetNormal():
	bS = buttonStatus.TEXTLOG_NORMAL

func OnClicked():
	if (Global.gamePaused):
		return
	print("Clicked on word: "+str(word)+" !!!")
	match bS:
		buttonStatus.TEXTLOG_INTERACTIBLE:
			print("And it's discoverable??")
			disable()
			Global.InteractableWordClicked.emit(word,self)
		buttonStatus.INVENTORY:
			print("And its an inventory item")
			Global.InventoryInteractibleClicked.emit(word,self)
		buttonStatus.COMMAND:
			print("And its an command item")
			Global.CommandInteractibleClicked.emit(word,self, true)
	#self.queue_free()

func moveButtonToLocation(goalButtonHandle:WordButton):
	print("YEP")
	var s = SimonTween.new()
	var u = SimonTween.new()
	var distanceDelta = goalButtonHandle.global_position - self.global_position + Vector2(0,self.size.y)
	goalButtonHandle.modulate.a = 0
	u.createTween(goalButtonHandle,"modulate:a",1,0.4,fadeCurve)
	await s.createTween(self,"global_position",distanceDelta,0.4).anotherParallel().createTween(self,"modulate:a",-1,0.4,fadeCurve).tweenDone
	deleteObject()

func deleteObject():
	self.queue_free()

func OnInteractionDone():
	Global.InteractableWordClicked_Finished.emit(word,self)
