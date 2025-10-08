extends Control

var progress : Array = []
var sceneName : String
var loadStatus : int = 0

func _ready() -> void:
	sceneName = Global.loadfinishPath
	ResourceLoader.load_threaded_request(sceneName)

func _process(_delta: float) -> void:
	loadStatus = ResourceLoader.load_threaded_get_status(sceneName, progress)
	
	$TEXT.text = str(floor(progress[0]*100)) + "%"
	$TEXT/loadProgress.value = progress[0]
	
	if loadStatus == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene = ResourceLoader.load_threaded_get(sceneName)
		get_tree().change_scene_to_packed(newScene)
