extends abilityTemp

@onready var timer : Timer = $durTimer

@export var healAmount : float = 10.5

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
	timer.stop()
	player.health += healAmount
	player.guiScene.update_health()
	player.moveType = funcType.CONTINUE
