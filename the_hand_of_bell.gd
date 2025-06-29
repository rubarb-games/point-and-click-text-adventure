extends Sprite2D

@export var positionMoveCurve:Curve
@export var isCommandHand:bool = false
@export var randNo:float

var isVisible:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (isCommandHand):
		Global.InventoryInteractibleClicked.connect(OnWordClicked)
	else:
		Global.InteractableWordClicked.connect(OnWordClicked)
		
	self.self_modulate.a = 0
	
	var positionMagnitude = 20
	
	var s = SimonTween.new()
	s.createTween(self,"position:x",positionMagnitude,Global.crazyLongPause+randNo,positionMoveCurve).setLoops(-1).anotherParallel(). \
	createTween(self,"position:y",positionMagnitude,Global.crazyLongPause*1.5+randNo,positionMoveCurve).setLoops(-1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnWordClicked(w, handle):
	if (isVisible):
		return
	
	isVisible = true
	var s = SimonTween.new()
	s.createTween(self,"self_modulate:a",1,Global.reallyLongPause*2)
