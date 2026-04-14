extends Node

var timer : float = 0.00
var timerActive : bool = false
var timerJustActive : bool = false

var pulseHintSeen : bool = false

#everything here is the default value
@export var settings = {
	"firstOpen" : true,
	"guiTrans" : 1,
	"toggleHint" : true,
	"toggleSmooth" : true
}

@export var playerData = {
	"Inventory" : [100,101,1],
	"Actives" : [100],
	"Passives" : [0],
	"Junk" : 0
}

@export var RUNDATA = {
	"gameExists" : false,
	"saferoomNum" : 0,
	"Cash" : 0,
	"Kills" : 0,
	"activeMods" : []
}

@export var abilityPaths = {
	0 : "res://assets/abilities/perks/2.tscn",
	1 : "res://assets/abilities/perks/2.tscn",
	2 : "res://assets/abilities/perks/2.tscn",
	3 : "res://assets/abilities/perks/3.tscn",
	4 : "res://assets/abilities/perks/4.tscn",
	5 : "res://assets/abilities/perks/5.tscn",
	100 : "res://assets/abilities/100.tscn",
	101 : "res://assets/abilities/101.tscn",
	102 : "res://assets/abilities/102.tscn",
	103 : "res://assets/abilities/103.tscn",
	104 : "res://assets/abilities/104.tscn",
	105 : "res://assets/abilities/105.tscn",
	106 : "res://assets/abilities/106.tscn"
}

@export var enemyModPaths = {
	"Lyte" : "res://assets/modifiers/enemies/stoplyte.tscn",
	"skeletron" : "res://assets/modifiers/enemies/skeletron.tscn",
	"Stargazer" : "res://assets/modifiers/enemies/stargazer.tscn",
	"Glare" : "res://assets/modifiers/enemies/glare.tscn"
}

@export var biomePaths = {
	-1 : "test",
	0 : "tutorial"
}
