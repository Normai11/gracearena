extends Node

var savedataPath = "user://SaveData.data"

var loadfinishPath : String

@export var playerData = {
	"Inventory":[100, 0],
	"Actives":[100],
	"Passives":[0]
}

@export var RUNDATA = {
	"gameExists":false,
	"saferoomNum":0,
	"Cash":0,
	"Kills":0
}

func _Save_Data():
	var save_file = FileAccess.open(savedataPath, FileAccess.WRITE)
	var save_data = {}
	save_data.Inventory = playerData["Inventory"]
	save_data.Actives = playerData["Actives"]
	save_data.Passives = playerData["Passives"]
	
	save_data.exists = RUNDATA["gameExists"]
	save_data.Saferoom = RUNDATA["saferoomNum"]
	save_data.Money = RUNDATA["Cash"]
	save_data.Kills = RUNDATA["Kills"]
	
	if save_file == null:
		print("FAILED TO SAVE FILE ", FileAccess.get_open_error())
		return
	
	var jsonString = JSON.stringify(save_data)
	save_file.store_string(jsonString)

func _Load_Data():
	if !FileAccess.file_exists(savedataPath):
		print("Save Data not found")
		return
	
	var savefile = FileAccess.open(savedataPath, FileAccess.READ)
	var jsonString = savefile.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(jsonString)
	if not parse_result == OK:
		print("JSON parse error ", json.get_error_message(), " on line ", json.get_error_line())
	
	var save_data = json.get_data()
	playerData["Inventory"] = save_data.Inventory
	playerData["Actives"] = save_data.Actives
	playerData["Passives"] = save_data.Passives
	
	RUNDATA["gameExists"] = save_data.exists
	RUNDATA["saferoomNum"] = int(save_data.Saferoom)
	RUNDATA["Cash"] = int(save_data.Money)
	RUNDATA["Kills"] = int(save_data.Kills)

func _ready() -> void:
	#_Save_Data()
	_Load_Data()
