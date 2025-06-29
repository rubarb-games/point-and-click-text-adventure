extends Control

var currentString:String = ""
var currentRules:Dictionary
@export var wordButtonToInstance:PackedScene
@export var textAreaHandle:Node2D
@export var textAreaGuide:Control

@export var InventoryManagerHandle:InventoryManager
@export var storyManagerHandle:StoryManager
@export var lastCommandText:RichTextLabel
@export var centerTextMarkerHandle:Control
var words:Array[WordData]
var wordButtons:Array[WordButton]

var textAreaPosition:Vector2
#
# TEMP VARIABLES
#

var tempString:String = "The _Door[noun is creaking at the other end of the room. One might _walk[verb over, maybe. Or just stand and _look[verb at it"

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.InteractableWordClicked.connect(OnInteractiveButtonClicked)
	Global.StoryPartialProgressed.connect(OnStoryPartialProgressed)
	Global.StoryProgressed.connect(OnStoryProgressed)
	Global.StoryChoiceMade.connect(OnStoryChoiceMade)
	Global.DumpText.connect(OnDumpText)
	Global.CommandMade.connect(OnCommandMade)
	#processText()
	textAreaPosition = textAreaHandle.global_position
	#lastCommandText.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func evaluateText():
	#print(storyManagerHandle.currentText)
	currentString = storyManagerHandle.currentText
	currentRules = storyManagerHandle.currentRules
	processRules()
	currentString = preProcessText(currentString)
	processTextRegex()

func preProcessText(text):
	var rx = RegEx.new()
	rx.compile(r"\[variable\s+(?P<var_name>\w+)\s*=\s*(?P<var_value>-?\d+)\](?P<var_content>.*?)\[/variable\]|(?P<tagged><(?P<tag>\w+)>\w+</\w+>)|(?P<punct>[.,!?;:])|(?P<words>\w+(?:['’]\w+)?|\d+)")
	var normalText = text
	var word_blocks = []
	
	for match in rx.search_all(text):
		if (match.get_string("var_name") != ""):
			print("Matched a variable")
			var var_name = match.get_string("var_name")
			var var_value = match.get_string("var_value")
			var content = match.get_string("var_content").strip_edges()
			
			word_blocks.append({
				"type": "variable",
				"name": var_name,
				"value": var_value,
				"content": content
			})
		elif (match.get_string("tagged") != ""):
			print("Matched a word"+str(match.get_string("words")))
			var content = match.get_string("tagged")
			word_blocks.append({
				"type": "word",
				"name": "",
				"content": content
			})
		elif (match.get_string("punct") != ""):
			print("Matched a word"+str(match.get_string("punct")))
			var content = match.get_string("punct")
			word_blocks.append({
				"type": "word",
				"name": "",
				"content": content
			})
		else:
			print("Matched a word"+str(match.get_string("words")))
			var content = match.get_string("words")
			
			word_blocks.append({
				"type": "word",
				"name": "",
				"content": content
			})
			
	var tmpCurrentString = ""
	for a in word_blocks:
		if (a["type"] == "variable"):
			if (Global.storyVariables.has(a["name"])):
				print("VALUE OF A VARIABLE IS: "+str(a["value"]))
				if (int(Global.storyVariables[a["name"]]) == int(a["value"])):
					tmpCurrentString += a["content"] + " "
			elif (!Global.storyVariables.has(a["name"]) and int(a["value"]) == -1):
				tmpCurrentString += a["content"] + " "
		else:
			tmpCurrentString += a["content"] + " "
		
	print("LETS SEE IF WE CAN RECONSTRUCT THIS!!!!!!")
	print(tmpCurrentString)
	print("AND THAT WAS IT!!!")
	return tmpCurrentString

func processRules():
	if (currentRules.size() > 0):
		for lab in currentRules.keys():
			#print(str(lab["name"])+"   - This be a label!!!!!")
			match lab:
				"location":
					Global.LocationEncountered.emit(currentRules[lab]["name"])
				"rule":
					Global.RuleEncountered.emit(currentRules[lab]["name"])
				"setVar":
					Global.storyVariables[currentRules[lab]["name"]] = currentRules[lab]["value"]

func dumpText(alsoProgress:bool = true):
	for w in range(wordButtons.size()):
		if (is_instance_valid(wordButtons[w])):
			wordButtons[w].Die()
	wordButtons = []
	if (!alsoProgress):
		return
	
	await get_tree().create_timer(0.5).timeout
	Global.StoryTextCleared.emit()
	
func instantlyKillAllText():
	var allTextKids = textAreaHandle.get_children()
	for tx in range(allTextKids.size()):
		allTextKids[tx].queue_free()
	
func fetchText():
	currentString = tempString
	
func parse_attributes(attr_str:String) -> Dictionary:
	var attr_regex = RegEx.new()
	attr_regex.compile(r'(\w+)="(.*?)"')
	var dict = {	}
	for match in attr_regex.search_all(attr_str):
		dict[match.get_string(1)] = match.get_string(2)
	return dict
	
func processTextRegex():
	var rx = RegEx.new()
	print(currentString)
	rx.compile(r"<(?P<tag>\w+)(?P<attrs>[^>]*)>(?P<content>.*?)</\w+>|(?P<punct>[.,!?;:])|(?P<word>\w+(?:['’]\w+)?|\d+)")
	#rx.compile(r'(<[^>]+>)|([^<]+)')
	var ry = RegEx.new()
	ry.compile(r"\b\w+\b")

	#var result = rx.search_all(currentString)
	var active_tags = []
	var word_list = []
	#print(result)
	var results = []
	for result in rx.search_all(currentString):
		if (result.get_string("tag") != ""):
			var tag = result.get_string("tag")
			var attrs_raw = result.get_string("attrs").strip_edges()
			var content = result.get_string("content")
			
			var attrs = parse_attributes(attrs_raw)
			results.append({
				"type": "tag",
				"tag": tag,
				"attributes": attrs,
				"content": content
			})
		elif result.get_string("punct") != "":
			results.append({
				"type": "punct",
				"content": result.get_string("punct")
			})
		elif result.get_string("word") != "":
			results.append({
				"type": "word",
				"content": result.get_string("word")
			})
	
	var entry = {}
	for m in results:
		match m["type"]:
			"tag":
				var tag = m["tag"]
				var attrs = m["attributes"]
				var content = m["content"]
				entry = {
					"word": content,
					"tag": tag,
					"attributes": attrs
				}
			"word":
				var content = m["content"]
				entry = {
					"word": content,
					"tag": ""
				}
			"punct":
				var content = m["content"]
				print("Hell yeah punctuation.. "+str(content))
				entry = {
					"word": m["content"],
					"tag": ""
				}
		word_list.append(entry)
		#print("TAG IS: "+str(tag)+" - FOR "+str(plain))
		#if tag != "":
		#	if (!tag.begins_with("</")):
		#		active_tags.append(tag)
		#	else:
		#		var tag_name = tag.substr(2,tag.length() - 3)
		#		#print(tag_name)
		#		for i in range(active_tags.size()):
		#			if active_tags[i].begins_with("<"+tag_name):
		#				active_tags.remove_at(i)
		#				break
		#elif plain != "":
		#	if (active_tags.size() > 0 and false):
		#		var entry = {
		#			"word": plain,
		#			"tag": active_tags[-1]
		#		}
		#		word_list.append(entry)
		#	else:	
		#		var word_matches = ry.search_all(plain)
		#		for wMatches in word_matches:
		#			var w = wMatches.get_string()
		#			var entry = {
		#				"word": w,
		#				"tag": active_tags.back() if active_tags.size() > 0  else null
		#			}
		#			word_list.append(entry)
					
	var s:String = ""
	var butt:WordButton
	
	for b in word_list:
		var wD = WordData.new()
		wD.word = b["word"]
		#If evaluateType() returns a rule, skip adding a button
		if (wD.evaluateType(b)):
			#print("Instantiating")
			butt = wordButtonToInstance.instantiate()
			textAreaHandle.add_child(butt)
			#butt.word = b.word
			butt.updateWordText(wD.word)
			butt.wData = wD
			wordButtons.append(butt)
			match b["tag"]:
				"redacted":
					butt.setGlitched()
					pass
				_:
					pass
			if (wD.isDiscoverable):
				if (!checkIfWordIsDiscovered(wD.word)):
					butt.SetInteractible()
					butt.toggleDrifting(true)
					butt.updateWord()
					butt.fadeIn()
			else:
				butt.updateWord()
				butt.fadeIn()
	#await get_tree().process_frame
	updateLayout()
	
func processText():
	#eprint("FETCHED! "+currentString)
	var wordsRaw:Array = currentString.split(" ")
	var words:Array[WordData] = []
	var tWord:WordData
	var tw
	words = []
	
	for w in wordsRaw:
		#print("Processing word "+str(w))
		tWord = WordData.new()
		if (w[0] == "["):
			w = w.substr(1)
			tw = w.split("]")
			match tw[0]:
				"noun":
					tWord.status = WordData.wordStatus.NOUN
				"verb":
					tWord.status = WordData.wordStatus.VERB
			tWord.isDiscoverable = true
			w = tw[1]
		
		tWord.word = w
		words.append(tWord)
	
	var s:String = ""
	var butt:WordButton
	
	for b in words:
		#print("Instantiating")
		butt = wordButtonToInstance.instantiate()
		textAreaHandle.add_child(butt)
		#butt.word = b.word
		butt.updateWordText(b.word)
		butt.wData = b
		wordButtons.append(butt)
		if (b.isDisabled):
			butt.disable()
		elif (b.isDiscoverable):
			if (!checkIfWordIsDiscovered(b.word)):
				butt.SetInteractible()
				butt.toggleDrifting(true)
				butt.updateWord()
				butt.fadeIn()
		else:
			butt.updateWord()
			butt.fadeIn()
	
	updateLayout()

func checkIfWordIsDiscovered(w:String):
	var wordButtons:Array = InventoryManagerHandle.inventoryAreaHandle.get_children() as Array[WordButton]
	
	for item in wordButtons:
		#print("Item == "+str(item.word))
		if (item.word == w):
			return true
	return false

func updateLayout():
	textAreaHandle.global_position = textAreaPosition
	var allWords = textAreaHandle.get_children()
	
	var idealHoriOffset = 0 #120
	var lineStart = textAreaGuide.global_position + textAreaGuide.size / 2
	var idealLineWidth = textAreaGuide.size.x / 2 + idealHoriOffset
	var startingCaretOffset:Vector2 = Vector2(0,-90)# - Vector2(idealLineWidth/2,0)
	var currentCaret:Vector2 = startingCaretOffset
	var idealHoriSpacing = 12
	var idealVertiSpacing = 40
	currentCaret[0] -= idealLineWidth / 2
	
	var row:Array[Array]
	var rowItems:Array = []
	
	var tSize
	#print("Caret is: "+str(currentCaret))
	#print("--------------")
	for ind in range(allWords.size()) :
		var word = allWords[ind] as WordButton
		rowItems.append(word)
		word.global_position = currentCaret + lineStart
		#print("Word is: "+str(word.word)+" and the pos is: "+str(word.global_position))
		tSize = word.size
		
		if (word.word == "N"):
			word.setInvisible()
			#word.updateWordText("-AA")
			currentCaret[0] = -idealLineWidth/2
			currentCaret[1] += idealVertiSpacing
			row.append(rowItems.duplicate())
			rowItems = []
		else:
			currentCaret[0] += tSize[0] + idealHoriSpacing
			if (currentCaret[0] > idealLineWidth):
				currentCaret[0] = -idealLineWidth/2
				currentCaret[1] += idealVertiSpacing
				row.append(rowItems.duplicate())
				rowItems = []
				
	row.append(rowItems.duplicate())
			
	var rowTotalWidth
	for r in row:
		rowTotalWidth = (r.size() * idealHoriSpacing) + startingCaretOffset.x
		for ri in r:
			#print("WORDIN!")
			var w = ri as WordButton
			rowTotalWidth += w.size.x
		var offset = (idealLineWidth / 2) - (rowTotalWidth / 2)
		for ru in r:
			ru.position.x += offset
			
		

func OnStoryProgressed():
	Global.spriteIrisPopup.emit(centerTextMarkerHandle.global_position)
	evaluateText()

func OnStoryChoiceMade(i):
	dumpText(true)

func OnDumpText(alsoProgress:bool):
	dumpText(alsoProgress)


func OnCommandMade(w):
	var s = SimonTween.new()
	lastCommandText.modulate.a = 0
	lastCommandText.text = w.replace("_"," ")
	s.createTween(lastCommandText,"modulate:a",1,Global.longPause)

func OnStoryPartialProgressed(w, a):
	var s = SimonTween.new()
	await s.createTween(lastCommandText,"modulate:a",-1,Global.veryShortPause).tweenDone

func OnInteractiveButtonClicked(word, buttonHandle):
	pass
	#buttonHandle.queue_free()
