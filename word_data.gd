class_name WordData
extends Resource

enum wordStatus { VERB, NOUN, OTHER, DISABLED }
var status:wordStatus = wordStatus.DISABLED

var word:String
var isDiscoverable:bool = false
