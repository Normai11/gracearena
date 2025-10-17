extends Node

@export var playerData = {
	"Inventory" : [100, 0],
	"Actives" : [100],
	"Passives" : [0]
}

@export var RUNDATA = {
	"gameExists" : false,
	"saferoomNum" : 0,
	"Cash" : 0,
	"Kills" : 0
}

@export var abilityPaths = {
	"100" : "res://Scenes/Abilities/100.tscn",
	"101" : "res://Scenes/Abilities/101.tscn",
	"102" : "res://Scenes/Abilities/100.tscn",
	"103" : "res://Scenes/Abilities/100.tscn"
}
