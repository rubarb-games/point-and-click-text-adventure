extends Control

@export var textHandle:RichTextLabel
@export var instanceText:PackedScene
var text:String

@export var textMoveCurve:Curve
@export var textOpacityCurve:Curve

var textPopupInProgress:bool = false

func _ready():
	Global.TextPopup.connect(OnTextPopup)
	textHandle.modulate.a = 0

func doPopup(tx, pos):
	var newText = instanceText.instantiate()
	self.add_child(newText)
	if (textPopupInProgress):
		pass
	
	textPopupInProgress = true
	newText.global_position = pos
	newText.text = tx
	newText.position += Vector2(randf_range(-10,10),randf_range(-10,10))
	newText.position.x -= newText.size.x / 2
	#updateWord(tx)
	
	var movementMagnitude = 40
	newText.position.y -= movementMagnitude
	newText.modulate.a = 0
	
	var s = SimonTween.new()
	await s.createTween(newText,"position:y",movementMagnitude * -1, Global.longPause,textMoveCurve).anotherParallel(). \
	createTween(newText,"modulate:a",1,Global.longPause,textOpacityCurve).tweenDone
	newText.modulate.a = 0
	newText.position = Vector2.ZERO
	newText.queue_free()
	textPopupInProgress = false

func updateWord(w:String):
	text = w
	textHandle.text = text
	textHandle.position.x = -(textHandle.size.x / 2)
	
func OnTextPopup(tx, pos):
	print("TEXT POPUP: "+str(tx)+" - "+str(pos))
	doPopup(tx,pos)
