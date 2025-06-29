extends Node

signal InteractableWordClicked #WORD, BUTTONHANDLE
signal InteractableWordClicked_Finished #WORD, BUTTONHANDLE

signal InventoryInteractibleClicked #WORD, BUTTONHANDLE
signal InventoryInteractibleClicked_Finished #WORD, BUTTONHANDLE

signal CommandInteractibleClicked
signal CommandInteractibleClicked_Finished

signal GlitchedClicked

signal StoryProgressed
signal StoryPartialProgressed

signal OnMakeStoryChoice
signal StoryTextCleared
signal StoryChoiceMade
signal CommandMade
signal DumpText
signal GoBack
signal ErrorPopup

signal DisplayDebugText #TEXT
signal DisplayDebugText2
signal DisplayDebugText3

signal ButtonClicked

signal TextPopup #TEXT, #POSITION
signal spriteIrisPopup #POSITION

signal LocationEncountered(location:String) #Location:string
signal RuleEncountered(rule:String)
signal StoryVariableEncountered(storyVar:Dictionary)

var storyVariables:Dictionary = {}

var timeScale:float = 1.0
var gamePaused:bool = false

var veryShortPause:float = 0.25
var shortPause:float = 0.5
var mediumPause:float = 0.8
var longPause:float = 1.0
var reallyLongPause:float = 1.6
var crazyLongPause:float = 5.0

func getStoryVar(key:String):
	if (storyVariables.has(key)):
		return storyVariables[key]
	return null
	
