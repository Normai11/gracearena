extends CharacterBody2D

enum states {
	PASSIVE,
	ENRAGED,
	TRANSITION
}

enum rageModes {
	HARM,
	SC_INPUT,
	SC_CIRCLE
}

@export var damage : float = 33.5
@export var damageKnockbackMult : float = 2.5
@export var defaultSpeed : float = 105.2
@export var enragedSpeedCap : float = 1225.2
@export var acceleration : float = 4.5
@export var enragedAccel : float = 2.0
@export_category("Spawn")
@export var forceEnraged : bool = false
@export var startingState = states.PASSIVE
@export var startingEnrageMode = rageModes.HARM

var target : Player
var direction : Vector2 = Vector2.ZERO
var state : states

func _ready() -> void:
	target = get_parent().playerReference
	if forceEnraged:
		state = states.ENRAGED

func _physics_process(delta: float) -> void:
	direction = global_position.direction_to(target.position)
	
	if state == states.ENRAGED:
		var velocityWeight : float = delta * enragedAccel
		velocity = lerp(velocity, direction * enragedSpeedCap, velocityWeight)
	elif state == states.PASSIVE:
		var velocityWeight : float = delta * acceleration
		velocity = lerp(velocity, direction * defaultSpeed, velocityWeight)
	else:
		velocity = lerp(velocity, Vector2.ZERO, delta * acceleration)
	
	move_and_slide()

func body_check(body: Node2D) -> void:
	if body is Player:
		if body.iFrames == 0:
			body.damage_by(damage, direction.x)
			velocity = -velocity * damageKnockbackMult
