extends abilityTemp

@onready var timer = $durTimer
@onready var hurtbox = $hurtbox
@onready var collision = $hurtbox/size

func _ready() -> void:
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
	if hurtbox.has_overlapping_bodies():
		attack_check(hurtbox)

func _ability_activate():
	timer.start()
	collision.disabled = false
	abDisplay._start_cooldown(cooldown)
	player._start_endlag(endlag + duration)
	player.moveType = function
	await(timer.timeout)
	_end_cooldown()

func _end_cooldown():
	timer.stop()
	collision.disabled = true
	player.moveType = funcType.CONTINUE
