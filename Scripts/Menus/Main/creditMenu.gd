extends Control

@onready var plateTemp = preload("res://Scenes/Menus/Main/credit_plate.tscn")
@onready var display = $plateContainer/Display
@onready var container = $plateContainer

var creditsPath : String = "res://Credits/"
var creditsData : Dictionary = {}
var creditsFiles : Array = []
var currentPlate : int

var tween : Tween
var finalVal : float


func _ready() -> void:
	#region Getting Files
	var creditsDir = DirAccess.open(creditsPath)
	creditsDir.list_dir_begin()
	var fileName = creditsDir.get_next()
	
	while fileName != "":
		if creditsDir.current_is_dir():
			print("Found Dire ", fileName) # SHOULD NOT HAPPEN, IF IT DOES THE GAME WILL CRASH !!!!
		else:
			print("Found File ", fileName) # SHOULD HAPPEN, IF IT DOES NOT THE GAME WILL CRASH !!!!
		fileName = creditsDir.get_next()
	creditsFiles = creditsDir.get_files()
	#endregion
	_begin_instantiating()
	tween = get_tree().create_tween()
	tween.kill()
	container.get_h_scroll_bar().allow_greater = true
	container.get_h_scroll_bar().allow_lesser = true
	finalVal = -828
	container.scroll_horizontal = finalVal

func _process(_delta: float) -> void:
	if !tween.is_running():
		container.scroll_horizontal = finalVal

func _begin_instantiating():
	var idx = 0
	currentPlate = 0
	for item in creditsFiles:
		creditsData = load_files((creditsPath + creditsFiles[idx]))
		var plateChild = plateTemp.instantiate()
		plateChild.plateID = creditsData["iconPath"] 
		plateChild.iconPath = creditsData["iconPath"] 
		plateChild.plateName = creditsData["plateName"] 
		plateChild.plateRole = creditsData["plateRole"] 
		plateChild.plateDesc = creditsData["plateDesc"] 
		plateChild.Links = creditsData["Links"] 
		plateChild.extraLink = creditsData["extraLink"] 
		plateChild.URL = creditsData["URLS"] 
		display.add_child(plateChild)
		idx += 1
	creditsData.clear()

func load_files(filePath : String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			return parsedResult
		else:
			print("Error Reading")
	else:
		print("File Nonexistent")

func _scroll_next() -> void:
	var total = creditsFiles.size()
	if currentPlate >= (total - 1):
		return
	currentPlate += 1
	
	if tween:
		tween.kill()
		container.scroll_horizontal = finalVal
	finalVal = container.scroll_horizontal + 550
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(container, "scroll_horizontal", finalVal, 1)

func _scroll_back() -> void:
	if currentPlate <= 0:
		return
	currentPlate -= 1
	if tween:
		tween.kill()
		container.scroll_horizontal = finalVal
	finalVal = container.scroll_horizontal - 550
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(container, "scroll_horizontal", finalVal, 1)
