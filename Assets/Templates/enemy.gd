class_name Enemy
extends Node2D

##
@export var moveSpeed : float = 200.0
## Amount of damage this enemy will deal when interacting with a player.
@export var damage : float = 10.0
## Amount of knockback this enemy will inflict when interacting with a player.
@export var knockbackAmount : float = 20.0
## The direction this enemy will start off in when added to the scene.
@export_range(-1, 1, 3) var startingDirection : int = 1
## Current direction this enemy is moving in at runtime.
var direction : int = 1
## Gravity
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	direction = startingDirection
