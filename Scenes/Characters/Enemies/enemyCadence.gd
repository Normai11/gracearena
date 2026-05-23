extends CharacterBody2D

enum states {
	SPAWNING,
	TICKING,
	SPEEDING
}

##
@export_range(0.4, 5, 0.01) var spawnDuration : float = 1.0
##
@export var tickRate : float = 0.7
##
@export var tickDistance : float = 1200.0
##
@export var tickDamage : float = 33.34
##
@export var tickWeight : float = 0.3

@onready var redact : CPUParticles2D = $REDACTION
@onready var hurtbox : Area2D = $Hurtbox

var playerReference : Player
var curTimer : float = 0.0
var curState : states = states.SPAWNING
var targetPos : Vector2 = Vector2.ZERO

func enable_redaction() -> void:
	redact.emitting = true

func _ready() -> void:
	var stageRef = get_tree().current_scene
	if stageRef is StageManager:
		stageRef.modEnemies.append(self)
	playerReference = get_tree().current_scene.find_child("Player")
	
	curTimer = tickRate
	$AnimationPlayer.play("spawn")

func _physics_process(delta: float) -> void:
	curTimer -= delta
	
	process_states(delta)
	
	velocity = velocity.lerp(Vector2.ZERO, tickWeight)
	move_and_slide()

func process_states(delta : float) -> void:
	match curState:
		states.SPAWNING:
			if curTimer <= 0 - tickRate:
				#curTimer = tickRate
				curState = states.TICKING
		states.TICKING:
			var curRate = tickRate
			if abs(global_position.distance_to(playerReference.global_position)) > tickDistance / 3:
				#print_rich("[color=purple]Too far!")
				curRate = tickRate / 4
			
			if curTimer <= 0:
				curTimer = curRate
				targetPos = global_position.direction_to(playerReference.global_position)
				velocity = targetPos * tickDistance
			check_damage()

func check_damage() -> void:
	if hurtbox.has_overlapping_bodies():
		var colliders = hurtbox.get_overlapping_bodies()
		for player in colliders:
			if player is Player:
				player.damage_player(tickDamage, 0)
