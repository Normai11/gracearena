class_name abilityTemp
extends Node

enum funcType {
	CONTINUE, # Apply all physics
	HALT, # Freeze in place entirely
	CONSTANT, # Freeze direction
	FALL, # Freeze X movement
	FLOAT # Freeze Y movement
}

@export_category("Identity")
@export var abilityID : int
@export var player : CharacterBody2D
@export var function = funcType.CONTINUE

@export_category("Ability")
@export var duration : float
@export var cooldown : float
@export var endlag : float
@export var onCooldown : bool

func _ready() -> void:
	print("Loaded!")

func _ability_activate():
	print("Ability " + str(abilityID) + " activated!")

func _check_cooldown():
	return onCooldown
