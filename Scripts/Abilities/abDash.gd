extends abilityTemp

@export var dashSpeed : float

@onready var timer = $durTimer

func _ready() -> void:
	timer.wait_time = duration
	print("Loaded!")

func _ability_activate():
	timer.start()
	abDisplay._start_cooldown(cooldown)
	player._start_endlag(endlag + duration)
	player.moveType = function
	await(timer.timeout)
	_end_cooldown()

func _end_cooldown():
	player.moveType = funcType.CONTINUE
	timer.stop()

func _physics_process(_delta: float) -> void:
	if timer.time_left > 0:
		player.iFrames = 2
		player.velocity.x = player.direction * dashSpeed
		player.velocity.y = 0
		player.move_and_slide()
