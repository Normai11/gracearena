extends Node

var timer : float = 0.00
var timerActive : bool = false
var timerJustActive : bool = false

@export var settings = {
	"guiTrans" : 1,
	"toggleHint" : true
}

@export var playerData = {
	"Inventory" : [100],
	"Actives" : [100],
	"Passives" : []
}

@export var RUNDATA = {
	"gameExists" : false,
	"saferoomNum" : 0,
	"Cash" : 0,
	"Kills" : 0
}

@export var abilityPaths = {
	"END" : "res://roomGen/roomEND.tscn",
	2 : "res://Scenes/Abilities/Perks/2.tscn",
	3 : "res://Scenes/Abilities/Perks/3.tscn",
	4 : "res://Scenes/Abilities/Perks/4.tscn",
	5 : "res://Scenes/Abilities/Perks/5.tscn",
	100 : "res://Scenes/Abilities/100.tscn",
	101 : "res://Scenes/Abilities/101.tscn",
	102 : "res://Scenes/Abilities/102.tscn",
	103 : "res://Scenes/Abilities/103.tscn",
	104 : "res://Scenes/Abilities/104.tscn"
}

@export var enemyModPaths = {
	"Lyte" : "res://Scenes/Characters/Mods/stoplyte.tscn"
}

@export var roomPaths = {
	0 : "res://roomGen/room0.tscn",
	1 : "res://roomGen/room_1.tscn",
	2 : "res://roomGen/room_2.tscn",
	3 : "res://roomGen/room_3.tscn",
	4 : "res://roomGen/room_4.tscn"
}
