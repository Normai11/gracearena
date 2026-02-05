extends Control
signal skillcheckComplete

@onready var inputPrompts : VBoxContainer = $escapeProgress/inputPrompts
@onready var inputPromptPath = preload("res://Scenes/Objects/skillcheckInputPrompt.tscn")
@onready var inputSC: TextureProgressBar = $escapeProgress
@onready var anims: AnimationPlayer = $escapeProgress/anims

@export var breakRequirement : float = 20.0
@export var drainInterval : float = 0.5

var rng = RandomNumberGenerator.new()
var scInputPrompt : Array[Vector2] = []
var scInputChildren : Array[int] = []
var visiblePrompts : int = 3
var scTimer : float = 0.0
var scInputProgress : float = 0.0

var skeletron : CharacterBody2D
var scInputTween : Tween
var activeTweens : Array[bool] = [false]

func reset_activeTweens_value(slot : int) -> void:
	activeTweens[slot] = false

func _ready() -> void:
	skeletron = get_parent().get_parent().get_parent()
	
	var idx = 0
	for num in visiblePrompts:
		scInputPrompt.append(randomize_input_prompt())
		add_prompt(scInputPrompt[idx], idx)
		idx += 1
	
	inputSC.max_value = breakRequirement
	anims.play("Visible")

func _process(delta: float) -> void:
	scTimer -= delta
	if scTimer <= 0:
		scTimer = drainInterval
		scInputProgress -= 0.5
		skeletron.target.health -= 0.75
		skeletron.target.guiScene.update_health()
		
		if scInputProgress <= 0:
			scInputProgress = 0
		elif scInputProgress >= breakRequirement - 2:
			skillcheckComplete.emit()
	if !activeTweens[0]:
		inputSC.value = scInputProgress

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

func add_prompt(prompt : Vector2, index : int):
	var instance = inputPromptPath.instantiate()
	
	instance.prompt = prompt
	instance.childID = index
	instance.correct.connect(skillcheck_input_check.bind(true))
	instance.incorrect.connect(skillcheck_input_check.bind(false))
	instance.evilParent = self
	if index == 0:
		instance.disabled = false
	
	inputPrompts.add_child.call_deferred(instance)
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
	scInputTween.connect("finished", reset_activeTweens_value.bind(0))

func next_prompt() -> void:
	scInputChildren.remove_at(0)
	for child in inputPrompts.get_children():
		child.childID -= 1
		if child.childID == 0:
			child.enable()
	add_prompt(randomize_input_prompt(), 2)
