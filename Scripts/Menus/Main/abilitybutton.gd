extends Control
signal _selected

@export var abilityID : int = 100 # [#]## is category, #[##] is itemID
@export var abFunc : Node

@onready var base = $Button
@onready var animations = $Button/animations
@onready var cdTimer = $cdTimer
@onready var keybind = $Prompt
@onready var cdDisp = $Cooldown

var promptID : int
var in_game : bool = false

var promptkeybind : Array = ["z", "x", "c", "a"]

func _ready() -> void:
	var path = "res://Sprites/Abilities/ab" + str(int(abilityID)) + ".png"
	base.get_child(0).texture = load(path)
	cdDisp.visible = false
	keybind.visible = false
	
	if in_game:
		keybind.visible = true
		keybind.text = promptkeybind[promptID]

func _process(_delta: float) -> void:
	cdDisp.text = str(snapped(cdTimer.time_left, 0.1))

func _focused():
	animations.play("hovering")

func _unfocused():
	animations.play("releasing")

func _on_pressed() -> void:
	if !in_game:
		if abilityID >= 100:
			DataStore.playerData["Actives"][0] = abilityID
		elif abilityID <= 99:
			DataStore.playerData["Passives"][0] = abilityID
		_selected.emit()
	else:
		_selected.emit(abilityID)

func _start_cooldown(duration):
	var shader = $Button/Display.material
	base.disabled = true
	cdDisp.visible = true
	cdTimer.start(duration)
	abFunc.onCooldown = true
	shader.set_shader_parameter("value", -0.15)
	shader.set_shader_parameter("exposure", 0.60)

func _end_cooldown() -> void:
	var shader = $Button/Display.material
	base.disabled = false
	cdDisp.visible = false
	abFunc.onCooldown = false
	shader.set_shader_parameter("value", 0.0)
	shader.set_shader_parameter("exposure", 0.5)
