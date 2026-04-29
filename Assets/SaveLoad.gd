extends Node

#@export var triggerFunction = -1:
	#set(value):
		#if value == 0:
			#save_data()
		#else:
			#load_data()

var savedataPath = "user://SaveData.data"
var configPath = "user://GlobalSettings.cfg"
var loadfinishPath : String

var saveDataTemplate : Dictionary = {
	"Inventory" : [],
	"activePerks" : [],
	"gameExists" : false,
	"runCurrency" : 0,
	"runSaferoom" : 0,
	"runModifiers" : []
}

func _ready() -> void:
	load_data()

func save_data():
	var saveFile = FileAccess.open(savedataPath, FileAccess.WRITE)
	var saveData = saveDataTemplate.duplicate()
	
	saveData["Inventory"] = DataStore.saveData["Inventory"]
	saveData["activePerks"] = DataStore.saveData["activePerks"]
	saveData["gameExists"] = DataStore.saveData["gameExists"]
	saveData["runCurrency"] = DataStore.saveData["runCurrency"]
	saveData["runSaferoom"] = DataStore.saveData["runSaferoom"]
	saveData["runModifiers"] = DataStore.saveData["runModifiers"]
	
	if saveFile == null:
		printerr("Saving file error ", FileAccess.get_open_error())
		return
	var jsonString = JSON.stringify(saveData, "\t")
	saveFile.store_string(jsonString)

func load_data():
	if !FileAccess.file_exists(savedataPath):
		printerr("Save file not found.")
		return
	var saveFile = FileAccess.open(savedataPath, FileAccess.READ)
	var jsonString = saveFile.get_as_text()
	var json = JSON.new()
	var parseResult = json.parse(jsonString)
	if parseResult != OK:
		printerr("JSON parse error ", json.get_error_message(), " on line ", json.get_error_line())
	
	var saveData = json.get_data()
	DataStore.saveData["Inventory"] = saveData["Inventory"]
	DataStore.saveData["activePerks"] = saveData["activePerks"]
	DataStore.saveData["gameExists"] = saveData["gameExists"]
	DataStore.saveData["runCurrency"] = saveData["runCurrency"]
	DataStore.saveData["runSaferoom"] = saveData["runSaferoom"]
	DataStore.saveData["runModifiers"] = saveData["runModifiers"]
	
