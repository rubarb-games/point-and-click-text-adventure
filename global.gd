extends Node

signal InteractableWordClicked #WORD, BUTTONHANDLE
signal InteractableWordClicked_Finished #WORD, BUTTONHANDLE

signal InventoryInteractibleClicked #WORD, BUTTONHANDLE
signal InventoryInteractibleClicked_Finished #WORD, BUTTONHANDLE

signal CommandInteractibleClicked
signal CommandInteractibleClicked_Finished

signal StoryProgressed
signal OnMakeStoryChoice
signal StoryTextCleared
signal StoryChoiceMade

var timeScale:float = 1.0
var gamePaused:bool = false

var veryShortPause:float = 0.25
var shortPause:float = 0.5
var mediumPause:float = 0.8
var longPause:float = 1.0
