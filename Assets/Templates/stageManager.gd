class_name StageManager
extends Node

@export var guiModScene : CanvasLayer

func _ready() -> void:
	for mod in DataStore.saveData["runModifiers"]:
		add_mod(mod)

func add_mod(modName : String) -> String:
	if DataStore.modScenes.has(modName):
		var scenePath = DataStore.modScenes[modName]
		var child = load(scenePath)
		child = child.instantiate()
		# custom "match" logic here
		guiModScene.add_child(child)
		return "Added mod " + modName
	else:
		return "[color=red]ERROR: Failed to add mod " + modName + "[/color]"
