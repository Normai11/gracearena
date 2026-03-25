extends abilityTemp

@onready var chain = $chainReel
@onready var timer = $durTimer
@onready var projectile = preload("res://Scenes/Objects/chainProjectile.tscn")

@export var reelLength : float = 300.0
@export var reelTime : float = 0.3
## Duration IN FRAMES
@export var reelDuration : int = 12
var currentDur : int
@export var grabCooldown : float = 2.5

var chainGrabbed : bool = false
var chainDamage : float = 0.0

func _ready() -> void:
	timer.wait_time = duration
	print("Loaded!")

func _physics_process(_delta: float) -> void:
	chain.target_position.x = reelLength * player.direction
	chain.position = player.position
	if timer.time_left > 0:
		chain.enabled = true
		if chain.is_colliding() && currentDur <= 0:
			var target = chain.get_collider()
			body_check(target)
			currentDur += 999
			chain.enabled = false
		currentDur -= 1

func free_chain() -> void:
	abDisplay.refresh_texture()
	timer.emit_signal("timeout")

func _ability_activate():
	player._start_endlag(endlag + duration)
	currentDur = reelDuration
	if chainGrabbed:
		abDisplay.altPath = ""
		chainGrabbed = false
		_end_cooldown()
		throw_object()
		abDisplay.refresh_texture()
		return
	player.moveType = function
	timer.start()
	await(timer.timeout)
	_end_cooldown()

func throw_object() -> void:
	var object = projectile.instantiate()
	object.startingPos = Vector2(player.position.x + 32, player.position.y)
	object.direction = player.direction
	object.dmg = chainDamage
	player.get_parent().add_child(object)

func _end_cooldown():
	timer.stop()
	player.moveType = funcType.CONTINUE
	if chainGrabbed:
		abDisplay._start_cooldown(grabCooldown)
	else:
		abDisplay._start_cooldown(cooldown)

func body_check(body: Node) -> void:
	#print(body)
	if body is Enemy:
		#body.position = Vector2(player.position.x - 30, player.position.y)
		body.reeling(player.position, reelTime)
		body.unchained.connect(free_chain)
		chainGrabbed = true
		abDisplay.altPath = "res://Sprites/Abilities/ab104ALT.png"
		chainDamage = body.health
