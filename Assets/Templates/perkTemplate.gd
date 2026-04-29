class_name Perk
extends Node
signal _hovered

## Reference scene for applying functions.
@export var playerParent : Player
@export_category("Identity")
## The name of the perk that will be displayed when hovered and in shop.
@export var perkName : String
## A short (or lengthy if needed) description of what this perk does.
## Will be displayed in shops and when clicked on in-game.
@export_multiline() var perkDescription : String
@export_category("Function")
## The amount of the time this perk must wait before being used again.
## Values under 5 seconds will be denied and have no cooldown.
@export var cooldown : float = 30.0
## How many times this perk can be used before SHATTERing.
## Setting this value to 0 (or below) will prevent it from SHATTERing.
@export var shatterRequire : int = 3
## Tracks the times this perk has been used.
var perkUses : int = 0

var onCooldown : bool = false
var curCooldown : float = 0.0

func _ready() -> void:
	print("Perk " + perkName + " loaded")

func _activate_perk() -> void:
	print("Perk " + perkName + " activated")
	onCooldown = true
	curCooldown = cooldown
	perkUses += 1
	if perkUses == shatterRequire:
		print("shatter function triggered")

func perk_hovered() -> void:
	_hovered.emit()
