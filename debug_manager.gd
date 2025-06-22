extends Control

@export var debugHandle:RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.DisplayDebugText.connect(OnDebugText)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnDebugText(tx):
	debugHandle.text = tx
