extends Enemy

@onready var edge = $edgeDetect
@onready var wall = $wallDetect

@export var turnDur : float = 0.3
@export var stunTime : float = 0.2

var tween : Tween
var state = States.MOVING
var distFrame : float = 0.0
var reelPos : float = 0.0

func reeling(position : Vector2, duration : float) -> void:
	isReeling = true
	distFrame = (bodyRef.position.x - position.x) / duration
	reelPos = position.x

func _physics_process(delta: float) -> void:
	if isReeling:
		$Hurtbox/CollisionShape2D.disabled = true
	else:
		$Hurtbox/CollisionShape2D.disabled = false
	
	if isReeling:
		#print(sign(distFrame))
		if sign(distFrame) == 1:
			if bodyRef.position.x >= reelPos:
				bodyRef.velocity.x = -distFrame
				bodyRef.move_and_slide()
			else:
				unchained.emit()
				isReeling = false
				queue_free()
		else:
			if bodyRef.position.x <= reelPos:
				bodyRef.velocity.x = -distFrame
				bodyRef.move_and_slide()
			else:
				unchained.emit()
				isReeling = false
				queue_free()
		return
	
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
