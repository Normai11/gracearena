extends CanvasLayer

@onready var http : HTTPRequest = $HTTPRequest
@onready var menu : Control = $Main
@onready var trackParent : ScrollContainer = $Main/trackParent
@onready var trackList : VBoxContainer = $Main/trackParent/Tracks

var trackFolderPath = "user://tracks"

func _ready() -> void:
	var test = get_tracks()
	print(test)

func get_tracks() -> Array:
	var output : Array = []
	
	if !DirAccess.dir_exists_absolute(trackFolderPath):
		var err = DirAccess.make_dir_recursive_absolute(trackFolderPath)
		if err != OK:
			printerr("Failed to create folder at " + str(trackFolderPath))
		else:
			print("Folder created at " + str(trackFolderPath))
	var searchPath = DirAccess.open(trackFolderPath)
	searchPath.list_dir_begin()
	var fileName = searchPath.get_next()
	
	while fileName != "":
		if searchPath.current_is_dir():
			print("Found Dire ", fileName)
		else:
			print("Found File ", fileName)
		fileName = searchPath.get_next()
	output = searchPath.get_files()
	
	return output
