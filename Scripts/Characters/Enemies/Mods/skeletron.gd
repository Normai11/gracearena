extends CharacterBody2D

enum states {
	PASSIVE,
	ENRAGED,
	TRANSITION
}

enum rageModes {
	HARM,
	SC_INPUT,
	SC_CIRCLE
}

@export var damage : float = 30.5
@export var damageKnockbackMult : float = 2.5
@export var defaultSpeed : float = 105.2
@export var enragedSpeedCap : float = 1325.2
@export var acceleration : float = 4.5
@export var enragedAccel : float = 2.0
@export var transDuration : float = 1.25
@export_category("Spawn")
@export var forceEnraged : bool = false
@export var startingState = states.PASSIVE
@export var startingEnrageMode = rageModes.HARM
@export var timerCap : float = 75.9
@export var timerStart : float = 30.9
@export var hitMax : int = 3

@onready var timeBar : TextureProgressBar = $HUD/Screen/TIMER
@onready var timeLabel : Label = $HUD/Screen/TIMER/Time

var target : Player
var direction : Vector2 = Vector2.ZERO
var playerHits : int = 0

var isEnraged : bool = false
var state : states
var timer : float = 0.0
var timeTween : Tween

func _ready() -> void:
	get_parent().specialStage = true
	timeTween = get_tree().create_tween()
	timeTween.kill()
	target = get_parent().playerReference
	timer = timerStart
	if forceEnraged:
		timer = 0.1

func _physics_process(delta: float) -> void:
	timer -= delta
	if !timeTween.is_valid():
		timeBar.value = timer
	
	var minutes = int(timer / 60)
	var seconds = timer - minutes * 60
	timeLabel.text = '%02d:%02d' % [minutes, seconds]
	
	if timer <= 0:
		timer = 0
		if !isEnraged:
			transition_enrage()
	direction = global_position.direction_to(target.position)
	
	if state == states.ENRAGED:
		var velocityWeight : float = delta * enragedAccel
		velocity = lerp(velocity, direction * enragedSpeedCap, velocityWeight)
		$Hurtbox.monitoring = true
	elif state == states.PASSIVE:
		var velocityWeight : float = delta * acceleration
		velocity = lerp(velocity, direction * defaultSpeed, velocityWeight)
		$Hurtbox.monitoring = false
	else:
		velocity = lerp(velocity, Vector2.ZERO, delta * acceleration)
	
	move_and_slide()

func switch_state(stateSwap : states) -> void:
	state = stateSwap

func transition_enrage() -> void:
	isEnraged = true
	playerHits = 0
	state = states.TRANSITION
	
	var transTime = get_tree().create_timer(transDuration)
	transTime.timeout.connect(switch_state.bind(states.ENRAGED))

func body_check(body: Node2D) -> void:
	if body is Player:
		if body.iFrames == 0:
			playerHits += 1
			body.damage_by(damage, direction.x)
			velocity = -velocity * damageKnockbackMult
			if playerHits >= hitMax:
				add_time()

func add_time(amt : float = 10.0) -> void:
	if isEnraged:
		isEnraged = false
		switch_state(states.PASSIVE)
	timer += (amt + 1)
	
	if timeTween:
		timeTween.kill()
	timeTween = get_tree().create_tween()
	timeTween.set_ease(Tween.EASE_OUT)
	timeTween.set_trans(Tween.TRANS_EXPO)
	
	timeTween.tween_property(timeBar, "value", timer - 1, 1)
