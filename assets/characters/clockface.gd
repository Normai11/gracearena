extends CharacterBody2D

enum strikeStates {
	APPEARING,
	ATTACKING,
	STRUCK,
	DISAPPEARING
}

@onready var cursor = preload("res://assets/characters/clockfaceCursor.tscn")

@export var appearTimer : float = 3.5
@export var strikeDamage : float = 33.34
@export var strikeDistance : float = 500.0
@export var strikeWeight : float = 0.3
@export var strikeWindup : float = 1.5

var active : bool = false
var playerTarget : Player
var targetPos : Vector2 = Vector2.ZERO
var curTimer : float = 0.0
var curState : strikeStates = strikeStates.DISAPPEARING
var clocked : bool = false

func set_active(on : bool) -> void:
	if on:
		active = true
		curTimer = appearTimer
		curState = strikeStates.APPEARING
	else:
		active = false
		curTimer = 0
		curState = strikeStates.DISAPPEARING

func _ready() -> void:
	#curTimer = appearTimer
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity = velocity.lerp(Vector2.ZERO, strikeWeight)
	if !active:
		return
	curTimer -= delta
	
	if curState == strikeStates.APPEARING:
		if curTimer >= appearTimer - 0.5:
			position = playerTarget.position
			return
		elif curTimer <= 0:
			curState = strikeStates.STRUCK
			curTimer = strikeWindup
	else:
		if curState == strikeStates.STRUCK && curTimer < strikeWindup/2 && !clocked:
			var cursorAdd = cursor.instantiate()
			
			clocked = true
			targetPos = global_position.direction_to(playerTarget.global_position)
			cursorAdd.global_position = playerTarget.global_position
			add_sibling(cursorAdd)
		
		if curTimer <= 0:
			if curState == strikeStates.STRUCK:
				clocked = false
				velocity = targetPos * strikeDistance
				curState = strikeStates.ATTACKING
			else:
				curState = strikeStates.STRUCK
				curTimer = strikeWindup

func _check_player(body: Node2D) -> void:
	if body is Player:
		body.damage_by(strikeDamage, 0, false)
