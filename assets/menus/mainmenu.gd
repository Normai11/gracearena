extends Node2D
#scrapped together, really just a proof of concept for the menu

var menuSetupRun = preload("res://assets/menus/nsetupMenu.tscn")
var menuSettings = preload("res://assets/menus/settingsMenu.tscn")

#func _ready() -> void:
	#pass

func _Start_Pressed() -> void:
	$Interface/Play.release_focus()
	if DataStore.RUNDATA["gameExists"] == true:
		$Interface/pregameContinue.visible = true
	else:
		var exists = has_node("Interface/runSetupScreen")
		if exists:
			return
		
		var sceneRun = menuSetupRun.instantiate()
		sceneRun.beginPressed.connect(_Create_Game)
		$Interface.add_child(sceneRun)

func _Create_Game() -> void:
	var loadingPath = load("res://assets/menus/loadingScreen.tscn")
	Global.loadfinishPath = "res://assets/test_stage.tscn"
	get_tree().change_scene_to_packed(loadingPath)

func _on_credits_pressed() -> void:
	var loadingPath = load("res://assets/menus/loadingScreen.tscn")
	Global.loadfinishPath = "res://assets/menus/creditMenu.tscn"
	get_tree().change_scene_to_packed(loadingPath)

func _Settings_Pressed() -> void:
	var sceneRun = menuSettings.instantiate()
	$Interface.add_child(sceneRun)
