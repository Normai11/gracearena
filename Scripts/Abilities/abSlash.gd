extends abilityTemp

@onready var timer = $durTimer
@onready var dashHurtbox = $dashHurtbox/size
@onready var slashHurtbox = $slashHurtbox/size

@export var dashCooldown : float = 12.6
@export var dashTimer : float = 0.3
var curHeld : float = 0.0
@export var dashVelocity : float = 9520.0

var cancelled : bool = false
var active : bool = false

func _ready() -> void:
	dashHurtbox.disabled = true
	slashHurtbox.disabled = true
	timer.wait_time = duration
	print("Loaded!")

func _physics_process(delta: float) -> void:
	$slashHurtbox.position = player.position
	if player.direction != 0:
		if player.direction == 1:
			$slashHurtbox.rotation_degrees = 0
			$dashHurtbox.rotation_degrees = 0
		else:
			$slashHurtbox.rotation_degrees = 180
			$dashHurtbox.rotation_degrees = 180
	if timer.time_left > 0 && active:
		$dashHurtbox.position = player.position
		var released = check_release()
		#print(released)
		curHeld += delta
		if curHeld >= dashTimer:
			cancelled = false
			trigger_attack()
		if released:
			cancelled = true
			timer.start(0.2)
			trigger_attack()

func _ability_activate():
	active = true
	curHeld = 0
	timer.start(duration)
	player._start_endlag(duration)
	player.moveType = function
	await(timer.timeout)
	_end_cooldown()

func trigger_attack() -> void:
	active = false
	player._start_endlag(endlag)
	if cancelled:
		dashHurtbox.disabled = true
		slashHurtbox.disabled = false
	else:
		dashHurtbox.disabled = false
		slashHurtbox.disabled = true
		#player.position.x += 238
		player.moveType = funcType.DISABLE
		player.iFrames = 7
		player.velocity.x += dashVelocity * player.direction

func _end_cooldown():
	timer.stop()
	if !cancelled:
		abDisplay._start_cooldown(dashCooldown)
	else:
		abDisplay._start_cooldown(cooldown)
	player.moveType = funcType.CONTINUE
	dashHurtbox.disabled = true
	slashHurtbox.disabled = true

func check_release() -> bool:
	if abilitySlot == 0:
		if !Input.is_action_pressed("primary") && !abDisplay.abButton.button_pressed:
			return true
	elif abilitySlot == 1:
		if !Input.is_action_pressed("secondary") && !abDisplay.abButton.button_pressed:
			return true
	elif abilitySlot == 2:
		if !Input.is_action_pressed("tertiary") && !abDisplay.abButton.button_pressed:
			return true
	elif abilitySlot == 3:
		if !Input.is_action_pressed("quarternary") && !abDisplay.abButton.button_pressed:
			return true
	return false

func body_check(body: Node) -> void:
	#print(body)
	if body is Enemy:
		body.damage_by(dmg, player.direction)
