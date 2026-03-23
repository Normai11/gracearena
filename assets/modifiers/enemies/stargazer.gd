extends Control

enum gazeStates {
	FREEZE,
	MOVEL,
	MOVER,
	JUMP
}

enum gazeTypes {
	DURATION,
	DISTANCE,
	AMOUNT
}

var starFaceRegions = {
	0 : Rect2(600, 300, 300, 300),
	1 : Rect2(300, 300, 300, 300),
	2 : Rect2(300, 300, 300, 300),
	3 : Rect2(0, 300, 300, 300),
}

@onready var sprite : Control = $Appearance
@onready var progressBar = $taskTimer
@onready var stateDisplay : Label = $taskTimer/curState
@onready var anims : AnimationPlayer = $Appearance/anims

@export var starShakeRange : Vector2 = Vector2(-5, 5)
@export var starShakeTime : float = 0.2
var curShake : float = 0.0
@export var forceGaze : bool = true
var gazing : bool = false
@export var gazeTimer : float = 5.0
var curTimer : float = 0.0
@export var gazeWait : Vector2 = Vector2(15, 60)

@export_group("Gaze Settings")
@export var typeDefaults : Dictionary = {
	"FREEZE" : Vector2(0.75, 1.5),
	"MOVEL" : Vector2i(50, 100),
	"MOVER" : Vector2i(50, 150),
	"JUMP" : Vector2i(1, 5)
}

var setyTween : Tween
var gazeRequirements : Array = [0.0, 0, 0, 0] ## FREEZE float, MOVES int, JUMP int
var curGazeStage : Array = [0.0, 0, 0, 0] ## ditto
var curGazeState : gazeStates
var playerTarget : Player
var moveDistance : float = 0.0

func set_atlas_region(regionData : Rect2, texture) -> void:
	var atlas = texture.texture
	atlas.region = Rect2(regionData)

func set_y_position(y : float, time : float) -> void:
	if setyTween:
		setyTween.kill()
	setyTween = get_tree().create_tween()
	setyTween.set_ease(Tween.EASE_OUT)
	setyTween.set_trans(Tween.TRANS_EXPO)
	setyTween.tween_property(self, "global_position", Vector2(global_position.x, y), time)

func _ready() -> void:
	curShake = starShakeTime
	anims.play("appear")
	global_position.x = 500

func _process(delta: float) -> void:
	curShake -= delta
	if gazing:
		curTimer -= delta
		gazeFunction(delta)
	
	if curShake <= 0:
		curShake = starShakeTime
		
		sprite.position = Vector2.ZERO
		sprite.position.x += randf_range(starShakeRange.x, starShakeRange.y)
		sprite.position.y += randf_range(starShakeRange.x, starShakeRange.y)
	
	progressBar.value = curTimer
	if curGazeState == gazeStates.JUMP:
		stateDisplay.text = str(curGazeStage[curGazeState]) + "/" + str(gazeRequirements[curGazeState])
	else:
		stateDisplay.text = str(snapped(curGazeStage[curGazeState], 0.1)) + "/" + str(gazeRequirements[curGazeState])

func starAppear() -> void:
	var stateArray = gazeStates.values()
	var gazeSet = stateArray.pick_random()
	gazeStart(gazeSet)

func gazeStart(gazeState : gazeStates) -> void:
	var defaultsArray : Array = typeDefaults.values()
	var randRange = snapped(randf_range(defaultsArray[gazeState].x, defaultsArray[gazeState].y), 0.1)
	if gazeState == gazeStates.JUMP:
		randRange = randi_range(defaultsArray[gazeState].x, defaultsArray[gazeState].y)
	gazeRequirements[gazeState] = randRange
	print(randRange)
	
	if gazeState == gazeStates.MOVEL or gazeState == gazeStates.MOVER:
		moveDistance = playerTarget.position.x
	curTimer = gazeTimer
	curGazeState = gazeState
	gazing = true
	progressBar.max_value = gazeTimer
	set_atlas_region(starFaceRegions[gazeState], $Appearance/Face)
	$Appearance/Face.flip_h = false
	if gazeState == gazeStates.MOVEL:
		$Appearance/Face.flip_h = true

func gazeFunction(delta : float) -> void:
	if curTimer <= 0:
		gazeJudge()
		return
	
	if curGazeState == gazeStates.FREEZE:
		if playerTarget.moveNode.get_movement_input() == 0:
			curGazeStage[curGazeState] += delta
			if curGazeStage[curGazeState] >= gazeRequirements[curGazeState]:
				curTimer = -2
	if curGazeState == gazeStates.MOVEL:
		if playerTarget.moveNode.get_movement_input() == -1 && !playerTarget.velocity.x == 0:
			curGazeStage[curGazeState] += abs(moveDistance - playerTarget.position.x) / 200
			if curGazeStage[curGazeState] >= gazeRequirements[curGazeState]:
				curTimer = -2
		elif playerTarget.moveNode.get_movement_input() == 1:
			moveDistance = playerTarget.position.x
	if curGazeState == gazeStates.MOVER:
		if playerTarget.moveNode.get_movement_input() == 1 && !playerTarget.velocity.x == 0:
			curGazeStage[curGazeState] += abs(moveDistance - playerTarget.position.x) / 200
			if curGazeStage[curGazeState] >= gazeRequirements[curGazeState]:
				curTimer = -2
		elif playerTarget.moveNode.get_movement_input() == -1:
			moveDistance = playerTarget.position.x
	if curGazeState == gazeStates.JUMP:
		if playerTarget.moveNode.get_jump(true) == true:
			curGazeStage[curGazeState] += 1
			if curGazeStage[curGazeState] >= gazeRequirements[curGazeState]:
				curTimer = 0.1

func gazeJudge() -> void:
	visible = false
