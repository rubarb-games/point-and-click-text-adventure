extends Control

@export var debugHandle:RichTextLabel
@export var debugHandle2:RichTextLabel
@export var debugHandle3:RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.DisplayDebugText.connect(OnDebugText)
	Global.DisplayDebugText2.connect(OnDebugText2)
	Global.DisplayDebugText3.connect(OnDebugText3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnDebugText(tx):
	debugHandle.text = tx

func OnDebugText2(tx):
	debugHandle2.text = tx

func OnDebugText3(tx):
	debugHandle3.text = tx
