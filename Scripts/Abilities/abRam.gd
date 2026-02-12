extends abilityTemp

@export var speedCap : float
var currentSpeed : float = 0.0
@export var ramPierce : int = 1
var kills : int = 0
var cancelled : bool = false

var originalGrav : float

@onready var timer = $durTimer
@onready var hurtbox = $hurtbox
@onready var collision = $hurtbox/size

func _ready() -> void:
	print(abilitySlot)
	abDisplay.abButton.toggle_mode = true
	timer.wait_time = duration
	collision.disabled = true
	print("Loaded!")

func _physics_process(delta: float) -> void:
	$crashCheck.position = player.position
	hurtbox.position = player.position
	if player.direction != 0:
		if player.direction == 1:
			hurtbox.rotation_degrees = 0
		else:
			hurtbox.rotation_degrees = 180
	if timer.time_left > 0:
		var velocityWeight : float = delta * (player.accel if player.moveNode.get_movement_input() else player.friction)
		player.velocity.x = lerp(player.velocity.x, player.direction * currentSpeed, velocityWeight)
		if player.velocity.y > 0:
			player.gravity = originalGrav * 1.5
		else:
			player.gravity = originalGrav
		if $crashCheck.is_colliding():
			timer.emit_signal("timeout")
			player.velocity.y = -1300
			player.accel = 90
			player.friction = 20
			player.stun(-player.direction, speedCap / 3)
			player.move_and_slide()
		if abilitySlot == 0:
			if !Input.is_action_pressed("primary") && !abDisplay.abButton.button_pressed:
				cancelled = true
				timer.emit_signal("timeout")
		elif abilitySlot == 1:
			if !Input.is_action_pressed("secondary") && !abDisplay.abButton.button_pressed:
				cancelled = true
				timer.emit_signal("timeout")
		elif abilitySlot == 2:
			if !Input.is_action_pressed("tertiary") && !abDisplay.abButton.button_pressed:
				cancelled = true
				timer.emit_signal("timeout")
		elif abilitySlot == 3:
			if !Input.is_action_pressed("quarternary") && !abDisplay.abButton.button_pressed:
				cancelled = true
				timer.emit_signal("timeout")
	if hurtbox.has_overlapping_bodies():
		attack_check(hurtbox)
		kills += 1
		currentSpeed -= 200
		if kills >= ramPierce:
			timer.emit_signal("timeout")
			player.velocity.y = -1300
			player.accel = 90
			player.friction = 20
			player.stun(-player.direction, speedCap / 3)
			player.move_and_slide()

func _ability_activate():
	$crashCheck.target_position.x = 25 * player.direction
	player.friction = 2
	player.accel = 2
	originalGrav = player.gravity
	timer.start()
	collision.disabled = false
	player._start_endlag(endlag + duration)
	player.moveType = function
	currentSpeed = speedCap
	await(timer.timeout)
	_end_cooldown()
	side_effect()

func _end_cooldown():
	timer.stop()
	abDisplay.abButton.button_pressed = false
	abDisplay._start_cooldown(cooldown)
	collision.set_deferred("disabled", true) 
	player._start_endlag(1)

func side_effect() -> void:
	player.gravity = originalGrav
	if 1 == 1:
	#if !cancelled:
		var tween = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween.tween_property(player, "friction", 20, 0.75)
		tween2.tween_property(player, "accel", 90, 0.75)
	else:
		pass #inflict slowness effect
	var Etimer = get_tree().create_timer(0.3)
	await Etimer.timeout
	player.moveType = funcType.CONTINUE
	kills = 0
