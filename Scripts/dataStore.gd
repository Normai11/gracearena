extends Node

var timer : float = 0.00

@export var playerData = {
	"Inventory" : [100, 0],
	"Actives" : [100,102],
	"Passives" : [0]
}

@export var RUNDATA = {
	"gameExists" : false,
	"saferoomNum" : 0,
	"Cash" : 0,
	"Kills" : 0
}

@export var abilityPaths = {
	"END" : "res://roomGen/roomEND.tscn",
	"100" : "res://Scenes/Abilities/100.tscn",
	"101" : "res://Scenes/Abilities/101.tscn",
	"102" : "res://Scenes/Abilities/102.tscn",
	"103" : "res://Scenes/Abilities/100.tscn"
}

@export var roomPaths = {
	0 : "res://roomGen/room0.tscn",
	#1 : "res://roomGen/room_1.tscn",
	1 : "res://roomGen/room_2.tscn",
	2 : "res://roomGen/room_3.tscn",
	#4 : "res://roomGen/room_4.tscn"
}
