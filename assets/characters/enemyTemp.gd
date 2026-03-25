class_name Enemy
extends Node
signal unchained

@export_category("Identity")
@export var bodyRef : CharacterBody2D
@export var enemyId : int
@export var hurtBox : Area2D ## here for easy reference
var enemyRendered : bool = false

@export_category("Attributes")
@export var moveSpeed : float = 200.0
@export var health : float = 20.0
@export var dmg : float = 12.0
@export var startingDirection : int = 1
@export var turnDur : float = 0.3
@export var stunTime : float = 0.2
var direction : int = 1
var distFrame : float = 0.0
var reelPos : float = 0.0

func _ready() -> void:
	direction = startingDirection

var isReeling : bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func reeling(position : Vector2, duration : float) -> void:
	isReeling = true
	distFrame = (bodyRef.position.x - position.x) / duration
	reelPos = position.x
