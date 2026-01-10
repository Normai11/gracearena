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

@onready var hurtBox : Area2D = $Hurtbox
@onready var timeBar : TextureProgressBar = $HUD/Screen/TIMER
@onready var timeLabel : Label = $HUD/Screen/TIMER/Time
@onready var inputSC : TextureProgressBar = $HUD/Screen/SC_Input
@onready var inputPromptPath = preload("res://Scenes/Menus/inGame/skillcheckInputPrompt.tscn")

var rng = RandomNumberGenerator.new()
var target : Player
var direction : Vector2 = Vector2.ZERO
var playerHits : int = 0

var isEnraged : bool = false
var state : states
var rageState : rageModes

var skillcheck : bool = false
var scTimer : float = 1.0
var scInputProgress : float = 0.0
var scInputPrompt : Array[Vector2] = []
var scInputChildren : Array[int] = []

var timer : float = 0.0
var dispTime : float = 0.0
var timeTween : Tween
var dispTween : Tween

func _ready() -> void:
	get_parent().specialStage = true
	state = startingState
	rageState = startingEnrageMode
	dispTween = get_tree().create_tween()
	timeTween = get_tree().create_tween()
	dispTween.kill()
	timeTween.kill()
	target = get_parent().playerReference
	timer = timerStart
	if forceEnraged:
		timer = 0.1

func _physics_process(delta: float) -> void:
	if timer <= 0:
		timer = 0
		if !isEnraged:
			transition_enrage()
	direction = global_position.direction_to(target.position)
	
	if skillcheck:
		target.stunned = true
		target.moveType = 1
		$Collision.disabled = false
		
		scTimer -= delta
		if scTimer <= 0:
			scInputProgress -= 0.25
			
			scTimer = 0.5
			target.health -= 0.5
			target.guiScene.update_health()
		
		velocity = lerp(velocity, Vector2.ZERO, delta * acceleration)
		move_and_slide()
		target.position = position
		target.velocity = Vector2.ZERO
		return
	else:
		$Collision.disabled = true
	
	if state == states.ENRAGED:
		var velocityWeight : float = delta * enragedAccel
		$Hurtbox.monitoring = true
		velocity = lerp(velocity, direction * enragedSpeedCap, velocityWeight)
	elif state == states.PASSIVE:
		var velocityWeight : float = delta * acceleration
		$Hurtbox.monitoring = false
		velocity = lerp(velocity, direction * defaultSpeed, velocityWeight)
	else:
		velocity = lerp(velocity, Vector2.ZERO, delta * acceleration)
	
	move_and_slide()

func _process(delta: float) -> void:
	timer -= delta
	if !timeTween.is_valid():
		timeBar.value = timer
		dispTime = timer
	
	var minutes = int(dispTime / 60)
	var seconds = dispTime - minutes * 60
	timeLabel.text = '%02d:%02d' % [minutes, seconds]
	
	if skillcheck:
		inputSC.visible = true
		
		if scInputProgress <= 0:
			scInputProgress = 0
		elif scInputProgress >= 14:
			release_rage_grab()
		
		inputSC.value = scInputProgress
	else:
		inputSC.visible = false

func switch_state(stateSwap : states) -> void:
	state = stateSwap

func randomize_input_prompt() -> Vector2:
	var newPrompt : Vector2
	var result = rng.randi_range(0, 3)
	if result == 0:
		newPrompt = Vector2(1, 0)
	elif result == 1:
		newPrompt = Vector2(-1, 0)
	elif result == 2:
		newPrompt = Vector2(0, 1)
	elif result == 3:
		newPrompt = Vector2(0, -1)
	
	return newPrompt

func randomize_ragemode() -> int:
	var newRage : int = rng.randi_range(0, rageModes.size() - 2)
	return newRage

func add_prompt(prompt : Vector2, index : int):
	var instance = inputPromptPath.instantiate()
	
	instance.prompt = prompt
	instance.childID = index
	instance.correct.connect(skillcheck_input_check.bind(true))
	instance.incorrect.connect(skillcheck_input_check.bind(false))
	instance.evilParent = self
	if index == 0:
		instance.disabled = false
	
	$HUD/Screen/SC_Input/inputPrompts.add_child(instance)
	scInputChildren.append(index)

func skillcheck_input_check(value : bool) -> void:
	if value:
		scInputProgress += 1
	else:
		scInputProgress -= 0.5

func next_prompt(delete : int) -> void:
	scInputChildren.remove_at(0)
	for child in $HUD/Screen/SC_Input/inputPrompts.get_children():
		child.childID -= 1
		if child.childID == 0:
			child.enable()
	add_prompt(randomize_input_prompt(), 2)

func release_rage_grab() -> void:
	velocity = Vector2((-650 * target.direction) * damageKnockbackMult, 400 * damageKnockbackMult)
	
	target.moveType = 0
	target.velocity.y = -400
	target.invulnerable = false
	target.stunned = false
	target.iFrames = target.iFrameMax + 20
	target.evilGrabbed = false
	skillcheck = false
	
	move_and_slide()
	target._start_endlag(0.25)
	target.guiScene.toggle_skillcheck(false)
	hurtBox.set_deferred("monitoring", true)
	playerHits += 1
	if playerHits >= hitMax:
		exit_enrage()

func start_rage_grab() -> void:
	hurtBox.set_deferred("monitoring", false)
	
	scInputProgress = 0.0
	scTimer = 1.0
	target.evilGrabbed = true
	target.invulnerable = true
	
	velocity = Vector2(velocity.x + (600 * direction.x), -1200)
	target.guiScene.toggle_skillcheck(true)
	
	if skillcheck:
		return
	target.health -= 15
	target.guiScene.update_health()
	var idx = 0
	scInputPrompt.clear()
	scInputChildren.clear()
	for child in $HUD/Screen/SC_Input/inputPrompts.get_children():
		child.queue_free()
	for i in 3:
		scInputPrompt.append(randomize_input_prompt())
		add_prompt(scInputPrompt[idx], idx)
		idx += 1
	skillcheck = true

func transition_enrage() -> void:
	isEnraged = true
	playerHits = 0
	state = states.TRANSITION
	
	var transTime = get_tree().create_timer(transDuration)
	transTime.timeout.connect(switch_state.bind(states.ENRAGED))

func exit_enrage() -> void:
	add_time()
	rageState = randomize_ragemode()

func body_check(body: Node2D) -> void:
	if body is Player:
		if body.iFrames == 0 && !skillcheck:
			if rageState == rageModes.HARM:
				body.damage_by(damage, direction.x)
				velocity = -velocity * damageKnockbackMult
				playerHits += 1
				if playerHits >= hitMax:
					exit_enrage()
			elif rageState == rageModes.SC_INPUT:
				start_rage_grab()

func add_time(amt : float = 10.0) -> void:
	if isEnraged:
		isEnraged = false
		switch_state(states.PASSIVE)
	timer += (amt + 1)
	
	if timeTween:
		timeTween.kill()
	timeTween = get_tree().create_tween()
	if dispTween:
		dispTween.kill()
	dispTween = get_tree().create_tween()
	
	timeTween.set_ease(Tween.EASE_OUT)
	timeTween.set_trans(Tween.TRANS_EXPO)
	dispTween.set_ease(Tween.EASE_OUT)
	dispTween.set_trans(Tween.TRANS_EXPO)
	
	timeTween.tween_property(timeBar, "value", timer - 1, 1)
	dispTween.tween_method(force_display, dispTime, timer, 1)

func force_display(value : float) -> void:
	dispTime = value
