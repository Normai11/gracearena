extends Node

var savedataPath = "user://SaveData.data"
var loadfinishPath : String

func _Save_Data():
	var save_file = FileAccess.open(savedataPath, FileAccess.WRITE)
	var save_data = {}
	save_data.Inventory = DataStore.playerData["Inventory"]
	save_data.Actives = DataStore.playerData["Actives"]
	save_data.Passives = DataStore.playerData["Passives"]
	
	save_data.exists = DataStore.RUNDATA["gameExists"]
	save_data.Saferoom = DataStore.RUNDATA["saferoomNum"]
	save_data.Money = DataStore.RUNDATA["Cash"]
	save_data.Kills = DataStore.RUNDATA["Kills"]
	
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
	DataStore.playerData["Inventory"] = save_data.Inventory
	DataStore.playerData["Actives"] = save_data.Actives
	DataStore.playerData["Passives"] = save_data.Passives
	
	DataStore.RUNDATA["gameExists"] = save_data.exists
	DataStore.RUNDATA["saferoomNum"] = (save_data.Saferoom)
	DataStore.RUNDATA["Cash"] = (save_data.Money)
	DataStore.RUNDATA["Kills"] = (save_data.Kills)

func _ready() -> void:
	#_Save_Data()
	_Load_Data()
	pass
