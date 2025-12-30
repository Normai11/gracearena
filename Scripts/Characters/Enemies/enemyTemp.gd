class_name Enemy
extends Node
signal unchained

@export_category("Identity")
@export var bodyRef : CharacterBody2D
@export var enemyId : int
@export var hurtBox : Area2D ## here for easy reference

@export_category("Attributes")
@export var moveSpeed : float = 200.0
@export var health : float = 20.0
@export var dmg : float = 12.0
@export var startingDirection : int = 1
var direction : int = 1

enum States {
	MOVING,
	TURNING,
	STUNNED,
	HIT,
}

func _ready() -> void:
	direction = startingDirection

var isReeling : bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
