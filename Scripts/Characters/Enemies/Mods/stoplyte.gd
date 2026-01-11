extends Node2D

@onready var timer : Timer = $waitTimer
@onready var intTimer : Timer = $intervalTimer
@onready var head : Sprite2D = $Head
@onready var anims : AnimationPlayer = $Head/Expressions

## Makes Stoplyte instantly appear after one second.
@export var forceAppear : bool = false
## A random float value between the X (minimum) and Y (maximum) values of this variable will be chosen.
## This value will later be Stoplyte's X position when appearing.
@export var appearXRange : Vector2 = Vector2(104, 1096)
## A random float value between the X (minimum) and Y (maximum) values of this variable will be chosen.
## This value will determine how long Stoplyte waits before appearing again.
@export var appearWaitRange : Vector2 = Vector2(10.0, 40.0)
## A random float value between the X (minimum) and Y (maximum) values of this variable will be chosen.
## This value will determine how long Stoplyte takes to switch its phase. (Green, Yellow, Red)
@export var intervalRange : Vector2 = Vector2(0.5, 3.0)
## This value determines how long Stoplyte waits before attacking.
@export var attackStall : float = 0.25
## If isAttacking is true, Stoplyte will check for player movement and attack.
## isAttacking becomes false when the player is damaged or when the "Relax" animation begins.
@export var isAttacking : bool = false
## DO NOT TAMPER WITH THIS VARIABLE !!!!!! If is true, Stoplyte will pause until this value becomes false.
@export var isStalling : bool = false

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var tween : Tween
var stallTween : Tween
var playerStrikes : int = 0
var isActive : bool = false

func _ready() -> void:
	position = Vector2(600, -100)
	if !forceAppear:
		var waitTime = rng.randf_range(appearWaitRange.x, appearWaitRange.y)
		timer.wait_time = waitTime
	timer.start()

func _process(delta: float) -> void:
	$debugStrike.text = "strikes: " + str(playerStrikes)
	if isAttacking:
		if Input.is_anything_pressed():
			playerStrikes += 1
			if playerStrikes == 3:
				get_parent().player.damage_by(100000, 0, false, true)
			isAttacking = false
	if get_parent().player.evilGrabbed:
		if !isStalling:
			set_stall_position(80, true)
		isStalling = true
		if !timer.is_stopped():
			timer.paused = true
		if !intTimer.is_stopped():
			intTimer.paused = true
	else:
		timer.paused = false
		intTimer.paused = false
		if isStalling:
			set_stall_position(128, false)
		isStalling = false

func _lyte_appear() -> void:
	isActive = true
	var randomX = rng.randf_range(appearXRange.x, appearXRange.y)
	position.x = randomX
	var greenStall = rng.randf_range(intervalRange.x, intervalRange.y)
	var yellowStall = rng.randf_range(intervalRange.x, intervalRange.y)
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", Vector2(position.x, 128), 0.4)
	shift_lyte_stage(Color("36e226"), greenStall)
	await intTimer.timeout
	shift_lyte_stage(Color("e8ca16"), yellowStall)
	await intTimer.timeout
	shift_lyte_stage(Color("bd221a"), attackStall)
	await intTimer.timeout
	anims.play("Attack")

func set_stall_position(Ypos : float, toggle : bool) -> void:
	if stallTween:
		stallTween.kill()
	stallTween = get_tree().create_tween()
	stallTween.set_ease(Tween.EASE_OUT)
	stallTween.set_trans(Tween.TRANS_SINE)
	if toggle:
		if !anims.is_playing() && isActive:
			head.frame = 4
			stallTween.tween_property(self, "position", Vector2(position.x, Ypos), 0.3)
	else:
		if !isAttacking && isActive:
			head.frame = 0
			stallTween.tween_property(self, "position", Vector2(position.x, 128), 0.3)

func shift_lyte_stage(color : Color, stallTime : float) -> void:
	head.material.set_shader_parameter("new_color", color)
	intTimer.start(stallTime)

func reroll_wait() -> void:
	var waitTime = rng.randf_range(appearWaitRange.x, appearWaitRange.y)
	timer.wait_time = waitTime
	timer.start()

func lyte_reset() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	anims.play("Relax")
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", Vector2(position.x, -100), 1)
	isActive = false
	reroll_wait()
