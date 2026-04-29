extends Enemy

enum enemyStates {
	MOVING,
	TURNING,
	SPAWNING
}
var curState : enemyStates

@export var body : CharacterBody2D
@export var turnTime : float = 0.3
var turnTimer : float = 0.3

@onready var hurtbox : Area2D = $Hurtbox
@onready var wallDetect : RayCast2D = $wallDetect
@onready var dropDetect : RayCast2D = $dropDetect

func _ready() -> void:
	super._ready()
	curState = enemyStates.SPAWNING
	switch_direction(direction)

func _physics_process(delta: float) -> void:
	process_movement(delta)
	if body.is_on_floor() && curState == enemyStates.SPAWNING:
		curState = enemyStates.MOVING
	wallDetect.target_position.x = 33.0 * direction
	dropDetect.position.x = 33.0 * direction
	
	if hurtbox.has_overlapping_bodies():
		var colliders = hurtbox.get_overlapping_bodies()
		for player in colliders:
			if player is Player:
				player.damage_player(damage, direction, knockbackAmount)

func process_movement(delta : float) -> void:
	if curState == enemyStates.MOVING:
		body.velocity.x = moveSpeed * direction
		if wallDetect.is_colliding() or !dropDetect.is_colliding():
			switch_direction(-direction)
	elif curState == enemyStates.TURNING:
		body.velocity.x = 0
		turnTimer -= delta
		if turnTimer <= 0:
			curState = enemyStates.MOVING
	
	body.velocity.y += gravity * delta
	
	body.move_and_slide()

func switch_direction(to : int) -> void:
	turnTimer = turnTime
	direction = to
	curState = enemyStates.TURNING
