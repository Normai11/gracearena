extends CanvasLayer

@onready var http : HTTPRequest = $HTTPRequest
@onready var menu : Control = $Main
@onready var trackParent : ScrollContainer = $Main/trackParent
@onready var trackList : VBoxContainer = $Main/trackParent/Tracks
@onready var nextButton : Button = $Main/next
@onready var prevButton : Button = $Main/previous

@onready var trackScene = preload("res://assets/menus/trackPlate.tscn")

var trackFolderPath = "user://tracks"
var scrollTween : Tween 

var plateList : Array = []
var curPlate : int = 0
var curScroll : int = 0

func _ready() -> void:
	set_tracks(get_tracks())
	trackParent.get_v_scroll_bar().allow_greater = true
	trackParent.get_v_scroll_bar().allow_lesser = true
	
	scrollTween = get_tree().create_tween()
	scrollTween.kill()

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
		output.append(fileName)
	
	return output

func set_tracks(list : Array) -> void:
	var idx : int = 0
	for track in list:
		idx += 1
		
		var plate = trackScene.instantiate()
		plate.trackPath = track
		plate.trackID = idx
		
		trackList.add_child(plate)
		plateList.append(plate)

func _process(delta: float) -> void:
	if scrollTween.is_running():
		pass
	else:
		trackParent.scroll_vertical = curScroll

func _next_track() -> void:
	curPlate += 1
	curScroll = floori(plateList[curPlate].position.y)
	if plateList.size() <= curPlate + 1:
		nextButton.disabled = true
	prevButton.disabled = false
	tween_scroll(curScroll)
	
func _previous_plate() -> void:
	curPlate -= 1
	curScroll = floori(plateList[curPlate].position.y)
	if curPlate - 1 < 0:
		prevButton.disabled = true
	nextButton.disabled = false
	tween_scroll(curScroll)

func tween_scroll(vertValue : int) -> void:
	if scrollTween:
		scrollTween.kill()
	scrollTween = get_tree().create_tween()
	scrollTween.set_ease(Tween.EASE_OUT)
	scrollTween.set_trans(Tween.TRANS_CUBIC)
	scrollTween.tween_property(trackParent, "scroll_vertical", vertValue, 0.15)
