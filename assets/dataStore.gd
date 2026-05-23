extends Node

var saveData : Dictionary = {
	"Inventory" : [],
	"activePerks" : [],
	"gameExists" : false,
	"runCurrency" : 0,
	"runSaferoom" : 0,
	"runModifiers" : []
}

var perkPaths : Dictionary[int, String] = {
	2 : "res://Scenes/Perks/perkWeight.tscn",
	3 : "res://Scenes/Perks/perkShield.tscn",
	4 : "res://Scenes/Perks/perkFeather.tscn",
}

var modScenes : Dictionary[String, String] = {
	"lyte" : "res://Scenes/Modifiers/modEnemies/Stoplyte.tscn"
}

@export var biomePaths = {
	-1 : "test",
	0 : "tutorial"
}
