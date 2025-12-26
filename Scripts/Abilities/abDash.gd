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
	player.friction = 3
	player.accel = 3
	await(timer.timeout)
	_end_cooldown()

func _end_cooldown():
	player.moveType = funcType.CONTINUE
	side_effect()
	timer.stop()

func _physics_process(_delta: float) -> void:
	if timer.time_left > 0:
		player.iFrames += 1
		player.velocity.x = player.direction * dashSpeed
		player.velocity.y = 0
		player.move_and_slide()
		if Input.is_action_just_pressed("jump"):
			timer.emit_signal("timeout")
			player.velocity.y = -player.jump_force / 1.25

func side_effect() -> void:
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(player, "friction", 20, 0.5)
	tween2.tween_property(player, "accel", 90, 0.5)
