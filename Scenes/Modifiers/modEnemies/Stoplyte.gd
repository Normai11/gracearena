extends Control

enum lightStates {
	WAITING,
	GREEN,
	YELLOW,
	ATTACKING,
	FALLBACK
}

## Range of time Stoplyte waits before appearing.
@export var appearInterval : Vector2 = Vector2(10, 45)
## Range of X values that Stoplyte can position itself at.
@export var appearX : Vector2 = Vector2(335, 1000)
## Range of time that Stoplyte's green light lasts (passive).
@export var passiveRange : Vector2 = Vector2(1, 5.75)
## Duration of Stoplyte's yellow light (warning).
@export var warnLength : float = 2.0
@export var moveWeight : float = 0.22
@export var curY : float
@export var curState : lightStates = lightStates.WAITING

@onready var light : ColorRect = $Head/Light
@onready var anims : AnimationPlayer = $Head/Anims
@onready var redact : CPUParticles2D = $Head/REDACTION

var playerReference : Player
var lightTimer : float = 0.0
var playerCaught : bool = false
var lightStrikes : int = 0

func _ready() -> void:
	playerReference = get_tree().current_scene.find_child("Player")
	reset_function()

func reset_function() -> void:
	lightTimer = randomize_timer(appearInterval)
	set_state(lightStates.WAITING, Color("55b328"), -168)

func enable_redaction() -> void:
	redact.emitting = true

func randomize_timer(timeRange : Vector2) -> float:
	var newTime : float = randf_range(timeRange.x, timeRange.y)
	return newTime

func _process(delta: float) -> void:
	lightTimer -= delta
	
	$Label.text = str(curState) + "\n" + str(lightStrikes)
	playerReference.existingGUI.strikeBar.value = (lightStrikes + 1) * 33
	
	position.y = lerp(position.y, curY, moveWeight)
	
	process_states()

func process_states() -> void:
	match curState:
		lightStates.WAITING:
			if lightTimer <= 0:
				lightTimer = randomize_timer(passiveRange)
				position.x = randomize_timer(appearX)
				set_state(lightStates.GREEN, Color("55b328"))
				playerCaught = false
		lightStates.GREEN:
			if lightTimer <= 0:
				#curState = lightStates.YELLOW
				lightTimer = warnLength
				set_state(lightStates.YELLOW, Color("d9b914ff"), 94)
		lightStates.YELLOW:
			#light.color = Color("d9b914ff")
			if lightTimer <= 0:
				lightTimer = 0.4
				set_state(lightStates.ATTACKING, Color("eb0024"), 110)
		lightStates.ATTACKING:
			if lightTimer <= 0:
				anims.play("strike")
				if abs(playerReference.velocity.x) >= (playerReference.moveSpeed - playerReference.crouchSubtractive) - 5 && !playerCaught:
					playerCaught = true
					lightStrikes += 1
					if lightStrikes == 3:
						playerReference.health = -1
		lightStates.FALLBACK:
			playerCaught = false

func set_state(state : lightStates, lightColor : Color = Color("eb0024"), newY : float = 72.0, weight : float = 0.22) -> void:
	curState = state
	light.color = lightColor
	moveWeight = weight
	curY = newY
