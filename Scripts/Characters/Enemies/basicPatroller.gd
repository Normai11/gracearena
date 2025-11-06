extends Enemy

enum States {
	MOVING,
	TURNING,
	STUNNED,
	HIT
}

@onready var edge = $edgeDetect
@onready var wall = $wallDetect

@export var turnDur : float = 0.3
@export var stunTime : float = 0.2

var tween : Tween
var state = States.MOVING

func _physics_process(delta: float) -> void:
	if !edge.is_colliding() or wall.is_colliding() && bodyRef.is_on_floor():
		turn(turnDur, States.TURNING, -direction)
	if state == States.MOVING:
		bodyRef.velocity.x = moveSpeed * direction
	
	bodyRef.velocity.y += gravity * delta
	bodyRef.move_and_slide()

func body_check(body: Node2D) -> void:
	if body is Player:
		if body.iFrames == 0:
			body.damage_by(dmg, direction)

func damage_by(amt, dir):
	health -= amt
	if health <= 0:
		queue_free()
		return
	turn(stunTime, States.STUNNED, -dir)
	knockback(300 * dir)

func knockback(amt):
	bodyRef.velocity.x = amt
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(bodyRef, "velocity", Vector2(0, 0), 0.1)

func return_ogState():
	state = States.MOVING

func turn(turnTime, endState, turnDir):
	var timer = get_tree().create_timer(turnTime)
	timer.timeout.connect(return_ogState)
	state = endState
	
	direction = turnDir
	if direction == 1:
		wall.rotation_degrees = 0
		edge.position.x = 32
	else:
		wall.rotation_degrees = 180
		edge.position.x = -32
	bodyRef.velocity.x = 0
