extends Button

@export var _ink_player:InkPlayer
var savedState:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnPressedGetState():
	print("GETTING STATE")
	print(_ink_player.get_state())
	savedState = _ink_player.get_state()

	
func OnPressedSetState():
	print(savedState)
	_ink_player.set_state(savedState)
	_ink_player.continue_story()
	pass
	#_ink_player.story_choice_made(0)
