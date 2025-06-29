class_name WordData
extends Resource

enum wordStatus { VERB, NOUN, ADJECTIVE, OTHER, GLITCHED, DISABLED }
var status:wordStatus = wordStatus.DISABLED

var word:String
var isDiscoverable:bool = false
var isDisabled:bool = false

func evaluateType(wDict:Dictionary):
	match wDict["tag"]:
		"noun":
			status = wordStatus.NOUN
			isDiscoverable = true
		"verb":
			status = wordStatus.VERB
			isDiscoverable = true
		"location":
			status = wordStatus.OTHER
			Global.LocationEncountered.emit(word)
			return false
		"rule":
			status = wordStatus.OTHER
			Global.RuleEncountered.emit(word)
			return false
		"redacted":
			status = wordStatus.GLITCHED
			return true
		"variable":
			pass
			return false
		_:
			status = wordStatus.OTHER
			
	return true
