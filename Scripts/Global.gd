extends Node

var savedataPath = "user://SaveData.data"
var configPath = "user://GlobalSettings.cfg"
var loadfinishPath : String

func _Save_Data():
	#region saveFile
	var save_file = FileAccess.open(savedataPath, FileAccess.WRITE)
	var save_data = {}
	save_data.Inventory = DataStore.playerData["Inventory"]
	save_data.Actives = DataStore.playerData["Actives"]
	save_data.Passives = DataStore.playerData["Passives"]
	save_data.Junk = DataStore.playerData["Junk"]
	
	save_data.exists = DataStore.RUNDATA["gameExists"]
	save_data.Saferoom = DataStore.RUNDATA["saferoomNum"]
	save_data.Money = DataStore.RUNDATA["Cash"]
	save_data.Kills = DataStore.RUNDATA["Kills"]
	save_data.Mods = DataStore.RUNDATA["activeMods"]
	
	if save_file == null:
		print("FAILED TO SAVE FILE ", FileAccess.get_open_error())
		return
	
	var jsonString = JSON.stringify(save_data, "\t")
	save_file.store_string(jsonString)
	#endregion
	#region configFile
	var config_file = ConfigFile.new()
	config_file.set_value("General", "firstOpen", DataStore.settings["firstOpen"])
	config_file.set_value("Video", "guiTransparency", DataStore.settings["guiTrans"])
	config_file.set_value("Game", "showHints", DataStore.settings["toggleHint"])
	config_file.save(configPath)
	#endregion

func _Load_Data():
	#region saveFile
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
	DataStore.playerData["Junk"] = save_data.Junk
	
	DataStore.RUNDATA["gameExists"] = save_data.exists
	DataStore.RUNDATA["saferoomNum"] = save_data.Saferoom
	DataStore.RUNDATA["Cash"] = save_data.Money
	DataStore.RUNDATA["Kills"] = save_data.Kills
	DataStore.RUNDATA["activeMods"] = save_data.Mods
	#endregion
	#region configFile
	var config_file = ConfigFile.new()
	var failCheck = config_file.load(configPath)
	if failCheck != OK:
		print("configFile " + configPath + "failed to load.")
		return
	
	DataStore.settings["guiTrans"] = config_file.get_value("Video", "guiTransparency")
	DataStore.settings["firstOpen"] = config_file.get_value("General", "firstOpen")
	DataStore.settings["toggleHint"] = config_file.get_value("Game", "showHints")
	#endregion

func _ready() -> void:
	if FileAccess.file_exists(savedataPath):
		_Load_Data()
	else:
		_Save_Data()
		print("generated new save file")
