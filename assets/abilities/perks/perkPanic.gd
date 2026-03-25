extends abilityTemp

@export var boostAmt : float ## ADDS ONTO CURRENT PLAYER SPEED!!!!!!
var defaultPlayerSpeed : float

func _ready() -> void:
	$durTimer.wait_time = duration
	defaultPlayerSpeed = player.move_speed

func _ability_activate():
	$durTimer.start()

func _process(delta: float) -> void:
	if $durTimer.time_left > 0:
		player.move_speed = (defaultPlayerSpeed + boostAmt)
	else:
		player.move_speed = defaultPlayerSpeed
