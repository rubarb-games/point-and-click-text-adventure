extends ColorRect

@export var fadeToBlackBHandle:ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_modulate.a = 1
	fadeToBlackBHandle.self_modulate.a = 1
	fadeFromBlack(fadeToBlackBHandle)
	await get_tree().create_timer(Global.reallyLongPause).timeout
	fadeFromBlack(self)


func fadeFromBlack(handle):
	self_modulate.a = 1
	var s = SimonTween.new()
	s.createTween(handle,"self_modulate:a",-1,Global.longPause)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
