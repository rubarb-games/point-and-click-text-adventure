extends Node

signal InteractableWordClicked #WORD, BUTTONHANDLE
signal InteractableWordClicked_Finished #WORD, BUTTONHANDLE

signal InventoryInteractibleClicked #WORD, BUTTONHANDLE
signal InventoryInteractibleClicked_Finished #WORD, BUTTONHANDLE

signal CommandInteractibleClicked
signal CommandInteractibleClicked_Finished

var timeScale:float = 1.0
var gamePaused:bool = false
