extends CharacterBody2D

## The base states that this special enemy can be in.
## PASSIVE: This enemy deals no damage, slows to a crawl, and only glides towards the player.
## ENRAGED: This enemy becomes hostile, speeding towards the player in seconds. See rageModes 
## for greater detail.
## TRANSITION: When entering this state, this enemy will stop in place momentarily before
## immediately entering its ENRAGED state.
enum states {
	PASSIVE,
	ENRAGED,
	TRANSITION
}

## The rage states that determine what this enemy will do when attacking the player while ENRAGED.
## HARM: This enemy charges into the player, being knocked back and dealing the base damage.
## SKILLCHECK_INPUT: This enemy grabs the player, holding both of them in place while a minigame
## appears on-screen. Arrow keys will appear, having to press a certain amount before the player
## breaks free.
## SKILLCHECK_CIRCLE: This state has not been developed yet.
enum rageModes {
	HARM,
	SC_INPUT,
	SC_CIRCLE
}

## Base damage for this special enemy. May have multipliers applied for certain rage modes.
@export var damage : float = 30.5
## The multiplier for the knockback this enemy recieves when HARM rage mode is active.
@export var damageKnockbackMult : float = 2.5
## Base speed for this enemy when its state is PASSIVE.
@export var defaultSpeed : float = 105.2
## Max speed for this enemy when its state is ENRAGED.
@export var enragedSpeedCap : float = 1325.2
## Acceleration value for when this enemy is PASSIVE.
@export var acceleration : float = 4.5
## Acceleration value for when this enemy is ENRAGED.
@export var enragedAccel : float = 2.0
## The length in seconds for when this enemy becomes ENRAGED.
@export var transDuration : float = 1.25
@export_category("Spawn")
## If true, this enemy will have its timer set to 0, immediately causing it to burst into its ENRAGED state.
@export var forceEnraged : bool = false
## The state this enemy will be in when added to the scene tree. 
@export var startingState = states.PASSIVE
## The state this enemy will be in when entering ENRAGED for the first time. After becoming passive again,
## the rage mode will be randomized.
@export var startingEnrageMode = rageModes.HARM
## The maximum value the timer can reach.
@export var timerCap : float = 75.9
## The value the timer will start at when the saferoom door is open.
@export var timerStart : float = 30.9
## The maximum amount of inputs (not including skillcheck drain and misses) required to drop the
## player out of being grabbed.
@export var skillcheckInputMax : float = 15.0
## The amount of hits this enemy will inflict before becoming PASSIVE again.
@export var hitMax : int = 3

@onready var hurtBox : Area2D = $Hurtbox
@onready var timeBar : TextureProgressBar = $HUD/Screen/TIMER
@onready var timeLabel : Label = $HUD/Screen/TIMER/Time
@onready var inputSC : TextureProgressBar = $HUD/Screen/SC_Input
@onready var inputPrompts : VBoxContainer = $HUD/Screen/SC_Input/inputPrompts
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
var scInputTween : Tween

func _ready() -> void:
	dispTween = get_tree().create_tween()
	timeTween = get_tree().create_tween()
	scInputTween = get_tree().create_tween()
	dispTween.kill()
	timeTween.kill()
	scInputTween.kill()
	
	get_parent().specialStage = true
	target = get_parent().playerReference
	state = startingState
	rageState = startingEnrageMode
	inputSC.max_value = skillcheckInputMax
	
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
			scInputProgress -= 0.5
			
			scTimer = 0.5
			target.health -= 0.75
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
		if scInputProgress <= 0:
			scInputProgress = 0
		elif scInputProgress >= skillcheckInputMax - 1:
			release_rage_grab()
		
		if !scInputTween.is_valid():
			inputSC.value = scInputProgress

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
	
	inputPrompts.add_child(instance)
	scInputChildren.append(index)

func skillcheck_input_check(value : bool) -> void:
	if value:
		scInputProgress += 1
	else:
		scInputProgress -= 2
	
	if scInputTween:
		scInputTween.kill()
	scInputTween = get_tree().create_tween()
	scInputTween.set_ease(Tween.EASE_OUT)
	scInputTween.set_trans(Tween.TRANS_EXPO)
	scInputTween.tween_property(inputSC, "value", scInputProgress, 0.2)

func next_prompt() -> void:
	scInputChildren.remove_at(0)
	for child in inputPrompts.get_children():
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
	$HUD/Screen/SC_Input/anims.play("Invisible")

func start_rage_grab() -> void:
	hurtBox.set_deferred("monitoring", false)
	
	scInputProgress = 0.0
	scTimer = 1.0
	target.evilGrabbed = true
	
	velocity = Vector2(velocity.x + (600 * direction.x), -1200)
	target.guiScene.toggle_skillcheck(true)
	
	if skillcheck:
		return
	target.damage_by(damage / 1.25, 0)
	target.guiScene.update_health()
	target.invulnerable = true
	var idx = 0
	scInputPrompt.clear()
	scInputChildren.clear()
	for child in inputPrompts.get_children():
		child.queue_free()
	for i in 3:
		scInputPrompt.append(randomize_input_prompt())
		add_prompt(scInputPrompt[idx], idx)
		idx += 1
	skillcheck = true
	$HUD/Screen/SC_Input/anims.play("Visible")

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
		if skillcheck:
			release_rage_grab()
	timer += (amt + 1)
	
	if timeTween:
		timeTween.kill()
	if dispTween:
		dispTween.kill()
	timeTween = get_tree().create_tween()
	dispTween = get_tree().create_tween()
	
	timeTween.set_ease(Tween.EASE_OUT)
	timeTween.set_trans(Tween.TRANS_EXPO)
	dispTween.set_ease(Tween.EASE_OUT)
	dispTween.set_trans(Tween.TRANS_EXPO)
	
	timeTween.tween_property(timeBar, "value", timer - 1, 1)
	dispTween.tween_method(force_display, dispTime, timer, 1)

func force_display(value : float) -> void:
	dispTime = value

func debugEnrage() -> void:
	timer = 0

func debugAddTime() -> void:
	add_time(5)
