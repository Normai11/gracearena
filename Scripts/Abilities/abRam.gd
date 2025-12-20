extends abilityTemp

@export var speedCap : float
@export var ramPierce : int = 1
var kills : int = 0

@onready var timer = $durTimer
@onready var hurtbox = $hurtbox
@onready var collision = $hurtbox/size

func _ready() -> void:
	print(abilitySlot)
	timer.wait_time = duration
	collision.disabled = true
	print("Loaded!")

func _physics_process(_delta: float) -> void:
	hurtbox.position = player.position
	if player.direction != 0:
		if player.direction == 1:
			hurtbox.rotation_degrees = 0
		else:
			hurtbox.rotation_degrees = 180
	if timer.time_left > 0:
		player.velocity.x = player.direction * speedCap
		player.move_and_slide()
		if player.is_on_wall():
			timer.emit_signal("timeout")
			player.velocity.y = -1300
			player.stun(-player.direction, speedCap / 3)
		if abilitySlot == 0:
			if !Input.is_action_pressed("primary"):
				timer.emit_signal("timeout")
		elif abilitySlot == 1:
			if !Input.is_action_pressed("secondary"):
				timer.emit_signal("timeout")
		elif abilitySlot == 2:
			if !Input.is_action_pressed("tertiary"):
				timer.emit_signal("timeout")
		elif abilitySlot == 3:
			if !Input.is_action_pressed("quarternary"):
				timer.emit_signal("timeout")

func _ability_activate():
	timer.start()
	collision.disabled = false
	player._start_endlag(endlag + duration)
	player.moveType = function
	await(timer.timeout)
	_end_cooldown()

func _end_cooldown():
	timer.stop()
	abDisplay._start_cooldown(cooldown)
	collision.set_deferred("disabled", true) 
	player.moveType = funcType.CONTINUE
	player._start_endlag(1)

func body_check(body: Node) -> void:
	#print(body)
	if body is Enemy:
		kills += 1
		body.damage_by(dmg, player.direction)
		if kills >= ramPierce:
			timer.emit_signal("timeout")
			player.velocity.y = -1300
			player.stun(-player.direction, speedCap / 3)
