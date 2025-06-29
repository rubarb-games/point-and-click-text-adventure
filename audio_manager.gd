extends Control

@export var GongHandle:AudioStreamPlayer2D
@export var ToneHandle:AudioStreamPlayer2D
@export var ErrorHandle:AudioStreamPlayer2D
@export var commandInputHandle:AudioStreamPlayer2D
@export var ToneDeepHandle:AudioStreamPlayer2D
@export var hitHurtHandle:AudioStreamPlayer2D

@export var MusicAHandle:AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.StoryProgressed.connect(OnStoryProgressed)
	Global.CommandInteractibleClicked.connect(OnButtonPressed)
	Global.InteractableWordClicked.connect(OnGetInteractibleWord)
	Global.InventoryInteractibleClicked.connect(OnButtonPressed)
	Global.ButtonClicked.connect(OnGeneralButtonClicked)
	Global.CommandMade.connect(OnCommandMade)
	Global.ErrorPopup.connect(OnError)
	Global.GlitchedClicked.connect(OnGlitchClicked)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func PlayGongSound():
	GongHandle.pitch_scale = randf_range(0.95,1.05)
	GongHandle.play()
	
func playToneA():
	ToneHandle.pitch_scale = randf_range(0.9,1.02)
	ToneHandle.play()

func playToneB():
	ToneDeepHandle.pitch_scale = randf_range(0.9,1.02)
	ToneDeepHandle.play()
	
func playError():
	ErrorHandle.pitch_scale = randf_range(0.95,1.05)
	ErrorHandle.play()
	
func playCommandSound():
	commandInputHandle.pitch_scale = randf_range(0.55,0.7)
	commandInputHandle.play()
	
func playHitHurt():
	hitHurtHandle.pitch_scale = randf_range(0.8,1.1)
	hitHurtHandle.play()
	
func OnStoryProgressed():
	PlayGongSound()

func OnButtonPressed(w):
	playToneA()

func OnGeneralButtonClicked():
	playToneB()

func OnCommandMade(w):
	playCommandSound()
	
func OnGetInteractibleWord(w, h):
	playCommandSound()
	
func OnError():
	playError()
	
func OnGlitchClicked(w, h):
	playHitHurt()
