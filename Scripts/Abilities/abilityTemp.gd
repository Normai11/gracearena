class_name abilityTemp
extends Node

enum funcType {
	CONTINUE, # Apply all physics
	HALT, # Freeze in place entirely
	CONSTANT, # Freeze direction
	FALL, # Freeze X movement
	FLOAT, # Freeze Y movement
	DISABLE # Nullify player movement input
}

@export_category("Identity")
@export var abName : String
@export var player : CharacterBody2D
@export var abDisplay : Control
@export var abilityID : int
@export var function = funcType.CONTINUE
var abilitySlot : int

@export_category("Ability")
@export var holdAbility : bool = false
@export var onCooldown : bool
@export var dmg : float
@export var duration : float
@export var cooldown : float
@export var endlag : float

func _ready() -> void:
	print("Loaded!")

func _ability_activate():
	print("Ability " + str(abilityID) + " activated!")

func _check_cooldown():
	return onCooldown
