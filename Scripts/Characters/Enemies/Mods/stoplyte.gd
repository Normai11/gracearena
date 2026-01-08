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

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var tween : Tween
var playerStrikes : int = 0

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

func _lyte_appear() -> void:
	var randomX = rng.randf_range(appearXRange.x, appearXRange.y)
	position.x = randomX
	var greenStall = rng.randf_range(intervalRange.x, intervalRange.y)
	var yellowStall = rng.randf_range(intervalRange.x, intervalRange.y)
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

func shift_lyte_stage(color : Color, stallTime : float) -> void:
	head.material.set_shader_parameter("new_color", color)
	intTimer.start(stallTime)

func reroll_wait() -> void:
	var waitTime = rng.randf_range(appearWaitRange.x, appearWaitRange.y)
	timer.wait_time = waitTime
	timer.start()

func lyte_reset() -> void:
	tween = get_tree().create_tween()
	anims.play("Relax")
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", Vector2(position.x, -100), 1)
	reroll_wait()
