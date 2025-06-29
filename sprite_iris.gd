extends Control

@export var opacityCurve:Curve
@export var scaleCurve:Curve
@export var spriteScene:PackedScene

var spriteArr:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.spriteIrisPopup.connect(OnSpritePopup)
	self_modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnSpritePopup(pos):
	var spri = spriteScene.instantiate()
	self.add_child(spri)
	spri.position = pos
	spriteArr.append(spri)
	
	var s = SimonTween.new()
	spri.modulate.a = 0
	spri.scale = Vector2(0.6,0.6)
	await s.createTween(spri,"scale",Vector2(0.7,0.7),Global.reallyLongPause,scaleCurve).anotherParallel(). \
	createTween(spri,"modulate:a",1,Global.reallyLongPause,opacityCurve).tweenDone
	
	spriteArr.erase(spri)
	spri.queue_free()
