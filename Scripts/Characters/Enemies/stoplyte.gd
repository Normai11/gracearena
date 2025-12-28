extends Node2D

@onready var timer : Timer = $waitTimer
@onready var intTimer : Timer = $intervalTimer
@onready var head : Sprite2D = $Head
@onready var anims : AnimationPlayer = $Head/Expressions

@export var forceAppear : bool = false
@export var appearWaitMin : float = 10.0
@export var appearWaitMax : float = 40.0
@export var minInterval : float = 0.5
@export var maxInterval : float = 3.0
@export var attackStall : float = 0.25

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var tween : Tween

func _ready() -> void:
	position = Vector2(600, -100)
	if !forceAppear:
		var waitTime = rng.randf_range(appearWaitMin, appearWaitMax)
		timer.wait_time = waitTime
		visible = false
	timer.start()

func _lyte_appear() -> void:
	var greenStall = rng.randf_range(minInterval, maxInterval)
	var yellowStall = rng.randf_range(minInterval, maxInterval)
	visible = true
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", Vector2(600, 128), 0.4)
	shift_lyte_stage(Color("36e226"), greenStall)
	#intTimer.start(greenStall)
	await intTimer.timeout
	shift_lyte_stage(Color("e8ca16"), yellowStall)
	await intTimer.timeout
	shift_lyte_stage(Color("bd221a"), attackStall)
	await intTimer.timeout
	anims.play("Attack")

func shift_lyte_stage(color : Color, stallTime : float) -> void:
	head.material.set_shader_parameter("new_color", color)
	intTimer.start(stallTime)

func lyte_attack() -> void:
	if Input.is_anything_pressed():
		get_parent().player.damage_by(15, 0, false)
	visible = false
	position = Vector2(600, -100)
	anims.play("RESET")
	reroll_wait()

func reroll_wait() -> void:
	var waitTime = rng.randf_range(appearWaitMin, appearWaitMax)
	timer.wait_time = waitTime
	timer.start()
