class_name WordData
extends Resource

enum wordStatus { VERB, NOUN, ADJECTIVE, OTHER, DISABLED }
var status:wordStatus = wordStatus.DISABLED

var word:String
var isDiscoverable:bool = false

func evaluateType(wDict:Dictionary):
	match wDict["tag"]:
		"[noun]":
			status = wordStatus.NOUN
		"[verb]":
			status = wordStatus.VERB
		"[location]":
			status = wordStatus.OTHER
			Global.LocationEncountered.emit(word)
			return false
		"[generic]":
			status = wordStatus.OTHER
			Global.RuleEncountered.emit("generic")
			return false
		"[historyClear]":
			status = wordStatus.OTHER
			Global.RuleEncountered.emit("historyClear")
			return false
		_:
			status = wordStatus.OTHER
			
	return true
