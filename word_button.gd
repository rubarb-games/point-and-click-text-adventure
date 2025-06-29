class_name WordButton
extends Control

enum buttonStatus { TEXTLOG_NORMAL, TEXTLOG_INTERACTIBLE, INVENTORY, COMMAND, GLITCHED, DEMON, PUNCTUATION, DISABLED }
var bS:buttonStatus

@export var buttonHandle:RichTextLabel
@export var interactableColor:Color = Color.DARK_KHAKI
@export var fadeCurve:Curve
@export var actualTextHandle:RichTextLabel
@export var particlesHandle:CPUParticles2D
@export var backingSprite:Sprite2D

var wData:WordData

var word:String = ""
var discoverable:bool = false
var inventoryItem:bool = false
var commandItem:bool = false

var glitchedText:bool = false
var glitchedWord:String = ""
var glitchedCharacters := ["#","@","&","$","%","!","*","-","+","?","X"]
var glitchedEffects := ["[shake rate=40 level=25 connected=0]","[shake rate=40 level=-85 connected=0]","[color=red]"]
var glitchedEffectsMild := ["[shake rate=40 level=5 connected=0]","[shake rate=40 level=-25 connected=0]","[color=red]"]

var active:bool = true
var defaultColor:Color
var highlightedColor:Color = Color.WHITE
@export var mutedColor:Color = Color.DIM_GRAY
@export var specialColor:Color = Color.DARK_KHAKI
@export var disabledColor:Color = Color(0.2,0.2,0.2,1)
var previousColor:Color

var isPunctuation:bool = false

@export var driftingCurve:Curve
var driftingTween:SimonTween
var driftOn:bool =false

@export var shakeCurve:Curve
var shakeTween:SimonTween

@export var rotShakeCurve:Curve
@export var backingSpriteDriftingCurve:Curve

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	defaultColor = highlightedColor
	previousColor = defaultColor
	self_modulate.a = 0.0
	particlesHandle.emitting = false
	backingSprite.visible = false
	var s:SimonTween = SimonTween.new()
	s.createTween(backingSprite,"position:x",5,5,backingSpriteDriftingCurve).setLoops(-1).anotherParallel(). \
	createTween(backingSprite, "position:y",5,6,backingSpriteDriftingCurve).setLoops(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match bS:
		buttonStatus.GLITCHED:
			var tmpWord = ""
			for a in word.length():
				tmpWord += glitchedEffects[randi() % glitchedEffects.size()] + glitchedCharacters[randi() % glitchedCharacters.size()]
			updateWordText(tmpWord,true)
		buttonStatus.DEMON:
			var tmpWord = ""
			for a in word.length():
				tmpWord += glitchedEffectsMild[randi() % glitchedEffectsMild.size()] + word[a]#+ glitchedCharacters[randi() % glitchedCharacters.size()]
			updateWordText(tmpWord,true)

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
	var whiteToRed = defaultColor - Color.RED
	buttonHandle.modulate = defaultColor
	var s = SimonTween.new()
	await s.createTween(buttonHandle,"modulate",whiteToRed,0.25,null,SimonTween.PINGPONG).anotherParallel(). \
	createTween(buttonHandle,"rotation",deg_to_rad(25),0.25,rotShakeCurve).tweenDone
	buttonHandle.modulate = defaultColor
	return true

func updateWordText(w:String, skipUpdatingWord:bool = false):
	if (!skipUpdatingWord):
		word = w
	
	word = word.replace("_"," ")
	self.text = "[center]"+w
	buttonHandle.text  = "[center]"+w
	#print("PARTICLE POSITION? "+str(particlesHandle.position))
	buttonHandle.pivot_offset = Vector2(self.size.x, self.size.y / 2)
	backingSprite.position = Vector2(self.size.x*2,self.size.y/2)
	await get_tree().process_frame
	particlesHandle.position = Vector2(self.size.x/2,self.size.y/4)#self.size / 2

func updateData(button:WordButton):
	word = button.word
	wData = button.wData

func disable():
	previousColor = defaultColor
	defaultColor = disabledColor
	#defaultColor = highlightedColor
	buttonHandle.self_modulate = defaultColor
	active = false
	toggleDrifting(false)

func makeNormal():
	defaultColor = highlightedColor
	buttonHandle.self_modulate = defaultColor
	active = false
	toggleDrifting(false)
	
func enable():
	defaultColor = previousColor
	buttonHandle.self_modulate = defaultColor
	active = true

func SetInteractible():
	bS = buttonStatus.TEXTLOG_INTERACTIBLE
	buttonHandle.self_modulate = interactableColor

func SetInventory():
	bS = buttonStatus.INVENTORY
	buttonHandle.self_modulate = defaultColor
	backingSprite.visible = true

func SetCommands():
	bS = buttonStatus.COMMAND

func SetNormal():
	bS = buttonStatus.TEXTLOG_NORMAL

func setHighlightedColor():
	defaultColor = highlightedColor
	buttonHandle.self_modulate = highlightedColor
	
func setMutedColor():
	defaultColor = mutedColor
	buttonHandle.self_modulate = mutedColor

func setSpecialColor():
	defaultColor = specialColor
	buttonHandle.self_modulate = specialColor

func setInvisible():
	buttonHandle.self_modulate.a = 0

func setUndiscoveredOptions():
	particlesHandle.emitting = true
	
func setDiscoveredOptions():
	particlesHandle.emitting = false
	
func setGlitched():
	glitchedText = true
	bS = buttonStatus.GLITCHED
	
func setDemon():
	bS = buttonStatus.DEMON
	defaultColor = Color.RED
	
func setPunctuation():
	bS = buttonStatus.PUNCTUATION
	isPunctuation = true

func Die():
	#print("I'm dying now!")
	var s = SimonTween.new()
	await s.createTween(self,"modulate:a",-1,Global.veryShortPause*randf_range(0.5,1.5)).tweenDone
	self.queue_free()

func OnClicked():
	if (Global.gamePaused or !active):
		return
	Global.ButtonClicked.emit()
	#print("Clicked on word: "+str(word)+" !!!")
	match bS:
		buttonStatus.TEXTLOG_INTERACTIBLE:
			if (active):
				print("And it's discoverable??")
				makeNormal()
				Global.InteractableWordClicked.emit(word,self)
		buttonStatus.INVENTORY:
			print("And its an inventory item")
			Global.InventoryInteractibleClicked.emit(word,self)
		buttonStatus.COMMAND:
			print("And its an command item")
			Global.CommandInteractibleClicked.emit(word,self, true)
		buttonStatus.GLITCHED:
			Global.GlitchedClicked.emit(word,self)
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
