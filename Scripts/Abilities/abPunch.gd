extends abilityTemp

@onready var timer = $durTimer
@onready var hurtbox = $hurtbox
@onready var collision = $hurtbox/size

@export var abDisplay : Control

func _ready() -> void:
	timer.wait_time = duration
	collision.disabled = true
	print("Loaded!")

func _physics_process(_delta: float) -> void:
	hurtbox.position = player.position
	if player.direction != 0:
		if player.direction == 1:
			collision.position.x = 32
		else:
			collision.position.x = -32

func _ability_activate():
	timer.start()
	collision.disabled = false
	abDisplay._start_cooldown(cooldown)
	player._start_endlag(endlag + duration)
	player.moveType = function
	await(timer.timeout)
	_end_cooldown()

func _end_cooldown():
	collision.disabled = true
	player.moveType = funcType.CONTINUE
