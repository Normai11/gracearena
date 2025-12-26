## Script that handles basic ability traits.
##
## Abilities must inherit from this script to work properly, as this template also determines ability durations, cooldowns, and GUI configuration.
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
@export var abName : String ## The name that will be displayed for the ability.
@export var player : CharacterBody2D ## Player node. Is set automatically when added to the player.
@export var abDisplay : Control ## The GUI node that displays information about this ability.
@export var abilityID : int ## The ability's ID according to its file path/name.
@export var function = funcType.CONTINUE ## Player's movement setting upon this ability's activation.
var abilitySlot : int

@export_category("Ability")
@export var holdAbility : bool = false ## If true, this ability keybind must be held in order to function.
@export var onCooldown : bool ## If true, this ability will not be able to be used until the cooldown is off.
@export var dmg : float ## The amount of damage the ability inflicts on enemies if the ability has a hitbox.
@export var duration : float ## The ability's lifespan.
@export var cooldown : float ## The amount of time the ability must wait before being used again.
@export var endlag : float ## The amount of time the player must wait before using another ability.

func _ready() -> void:
	print("Loaded!")

func _ability_activate():
	print("Ability " + str(abilityID) + " activated!")

func _check_cooldown():
	return onCooldown
