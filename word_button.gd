class_name WordButton
extends Control

enum buttonStatus { TEXTLOG_NORMAL, TEXTLOG_INTERACTIBLE, INVENTORY, COMMAND, DISABLED }
var bS:buttonStatus

@export var buttonHandle:RichTextLabel
@export var interactableColor:Color = Color.DARK_KHAKI
@export var fadeCurve:Curve
@export var actualTextHandle:RichTextLabel

var wData:WordData

var word:String = ""
var discoverable:bool = false
var inventoryItem:bool = false
var commandItem:bool = false

var active:bool = true

@export var driftingCurve:Curve
var driftingTween:SimonTween
var driftOn:bool =false

@export var shakeCurve:Curve
var shakeTween:SimonTween

@export var rotShakeCurve:Curve

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	self_modulate.a = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateWord(isDiscoverable:bool = false):
	buttonHandle.text = word

func toggleDrifting(on:bool = true):
	var r = randf_range(0.8,1.8)
	if (!driftOn and on):
		driftingTween = SimonTween.new()
		driftingTween.createTween(buttonHandle,"position:y",3,1.25*r,driftingCurve,SimonTween.PINGPONG).setLoops(-1)
	elif (driftOn and !on):
		driftingTween.stop()
		
		buttonHandle.position = Vector2(0,0)
	driftOn = on

func fadeIn():
	var r = randf_range(0.1,0.9)
	var f = SimonTween.new()
	self.modulate.a = 0
	f.createTween(self,"modulate:a",1,r)

func shake():
	shakeTween = SimonTween.new()
	await shakeTween.createTween(buttonHandle,"position:y",20,0.2,shakeCurve).tweenDone
	return true

func errorShake():
	var whiteToRed = Color.WHITE - Color.RED
	buttonHandle.modulate = Color.WHITE
	var s = SimonTween.new()
	await s.createTween(buttonHandle,"modulate",whiteToRed,0.25,null,SimonTween.PINGPONG).anotherParallel(). \
	createTween(buttonHandle,"rotation",deg_to_rad(25),0.25,rotShakeCurve).tweenDone
	buttonHandle.modulate = Color.WHITE
	return true

func updateWordText(w:String):
	word = w
	self.text = "[center]"+w
	buttonHandle.text  = "[center]"+w

	buttonHandle.pivot_offset = Vector2(self.size.x, self.size.y / 2)

func updateData(button:WordButton):
	word = button.word
	wData = button.wData

func disable():
	buttonHandle.self_modulate = Color.WHITE
	active = false
	toggleDrifting(false)

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

func Die():
	print("I'm dying now!")
	var s = SimonTween.new()
	await s.createTween(self,"modulate:a",-1,0.1).tweenDone
	self.queue_free()

func OnClicked():
	if (Global.gamePaused):
		return
	print("Clicked on word: "+str(word)+" !!!")
	match bS:
		buttonStatus.TEXTLOG_INTERACTIBLE:
			if (active):
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

func moveButtonToLocation(goalObjectHandle:Node, deleteAtEnd:bool = true, fadeGoal:bool = true):
	var origPos = self.global_position
	var s = SimonTween.new()
	var u = SimonTween.new()
	var distanceDelta = goalObjectHandle.global_position - self.global_position + Vector2(0,self.size.y)
	if (fadeGoal):
		goalObjectHandle.modulate.a = 0
		u.createTween(goalObjectHandle,"modulate:a",1,0.4,fadeCurve)
	await s.createTween(self,"global_position",distanceDelta,0.4).anotherParallel().createTween(self,"modulate:a",-1,0.4,fadeCurve).tweenDone
	
	if (deleteAtEnd):
		deleteObject()
	else:
		self.global_position = origPos
		if (fadeGoal):
			await s.createTween(self,"modulate:a",1,Global.veryShortPause).tweenDone
			
	return true

func deleteObject():
	self.queue_free()

func OnInteractionDone():
	Global.InteractableWordClicked_Finished.emit(word,self)
