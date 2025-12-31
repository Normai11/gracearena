extends Enemy

enum States {
	MOVING,
	TURNING,
	STUNNED,
	HIT,
	RELEASING
}

@export var sporeWindup : float = 0.3
@export var sporeDrag : float = 1.0
@export var sporeEndlag : float = 2
@export var sporeDamage : float = 18.0

@onready var edge = $edgeDetect
@onready var wall = $wallDetect
@onready var spore = $sporeBox
@onready var timerWind = $sporeFreeze
@onready var timerDrag = $sporeDrag
@onready var timerLag = $sporeEndlag

var tween : Tween
var state : States = States.MOVING
var sporePos : Vector2 = Vector2.ZERO

func _ready() -> void:
	turn(0.01, States.TURNING, startingDirection)
	timerDrag.wait_time = sporeDrag
	timerWind.wait_time = sporeWindup
	timerLag.wait_time = sporeEndlag

func _physics_process(delta: float) -> void:
	if !enemyRendered:
		return
	if timerDrag.time_left != 0:
		spore.position = sporePos - bodyRef.position
	else:
		spore.position = Vector2.ZERO
	if state == States.RELEASING:
		bodyRef.velocity = Vector2.ZERO
		bodyRef.move_and_slide()
		return
	
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

func body_check_spore(body: Node2D) -> void:
	if body is Player:
		if body.iFrames == 0:
			body.damage_by(sporeDamage, 0, false, false)

func damage_by(amt, dir):
	health -= amt
	if health <= 0:
		queue_free()
		return
	turn(stunTime, States.STUNNED, -dir)
	knockback(300 * dir)
	if timerLag.time_left == 0:
		sporePos = bodyRef.position
		timerWind.start()
		state = States.RELEASING

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

func _windup_end() -> void:
	spore.monitoring = true
	spore.get_child(0).debug_color.a = 107.0/255.0
	timerDrag.start()

func _drag_end() -> void:
	spore.monitoring = false
	spore.get_child(0).debug_color.a = 0
	return_ogState()
	timerLag.start()

func _enemy_rendered() -> void:
	enemyRendered = true
	bodyRef.apply_floor_snap()
