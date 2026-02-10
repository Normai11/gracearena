extends Node

var timer : float = 0.00
var timerActive : bool = false
var timerJustActive : bool = false

var pulseHintSeen : bool = false

#everything here is the default value
@export var settings = {
	"firstOpen" : true,
	"guiTrans" : 1,
	"toggleHint" : true
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
	0 : "res://Scenes/Abilities/Perks/2.tscn",
	1 : "res://Scenes/Abilities/Perks/2.tscn",
	2 : "res://Scenes/Abilities/Perks/2.tscn",
	3 : "res://Scenes/Abilities/Perks/3.tscn",
	4 : "res://Scenes/Abilities/Perks/4.tscn",
	5 : "res://Scenes/Abilities/Perks/5.tscn",
	100 : "res://Scenes/Abilities/100.tscn",
	101 : "res://Scenes/Abilities/101.tscn",
	102 : "res://Scenes/Abilities/102.tscn",
	103 : "res://Scenes/Abilities/103.tscn",
	104 : "res://Scenes/Abilities/104.tscn",
	105 : "res://Scenes/Abilities/105.tscn",
	106 : "res://Scenes/Abilities/106.tscn"
}

@export var enemyModPaths = {
	"Lyte" : "res://Scenes/Characters/Mods/stoplyte.tscn",
	"skeletron" : "res://Scenes/Characters/Mods/skeletron.tscn"
}
