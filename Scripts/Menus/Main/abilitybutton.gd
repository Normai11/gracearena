extends Control
signal _selected

@export var isAbility : bool = true
@export var inputID : int = 100
@export_category("Ability")
@export var abFunc : Node
@export var inGame : bool = false
@export_category("Perk")
@export var perkFunc : Node
var texturePath : String

@onready var Cd = $cdTimer
@onready var abButton = $Ability/abButton
@onready var abInfo = $Ability/abInfo
@onready var cdDisp = $Ability/abCooldown
@onready var perkCd = $Perk/perkCooldown
@onready var perkBase = $Perk

var tween : Tween

var inputName : String = "Placeholder"
var promptID : int = 0
var hold : bool = false

var promptkeybind : Array = ["Z", "X", "C", "A"]

func _ready() -> void:
	var path = "res://Sprites/Abilities/ab" + str(int(inputID)) + ".png"
	if FileAccess.file_exists(path):
		abButton.get_child(0).texture = load(path)
		perkBase.get_child(0).texture = load(path)
	
	if isAbility:
		if inGame:
			var infoString : String
			if hold:
				$Ability/holdIndicator.visible = true
			else:
				$Ability/holdIndicator.visible = false
			infoString = str(promptkeybind[promptID]) + "\n\n\n\n" + inputName
			abInfo.text = infoString
		else:
			abInfo.visible = false
			$Ability/holdIndicator.visible = false
		
		$Perk.visible = false
		cdDisp.visible = false
	else:
		$Ability.visible = false
		perkCd.visible = false
		self.custom_minimum_size = Vector2(48.0, 48.0)
		
		if FileAccess.file_exists(texturePath):
			perkBase.get_child(0).texture = load(texturePath)

func _process(_delta: float) -> void:
	cdDisp.text = str(snapped(Cd.time_left, 0.1))
	perkCd.text = str(snapped(Cd.time_left, 1))
	if inGame:
		$".".modulate.a = DataStore.settings["guiTrans"]

func _on_abButton_pressed() -> void:
	if inGame:
		_selected.emit(inputID)
	else:
		if inputID >= 100:
			DataStore.playerData["Actives"].clear()
			DataStore.playerData["Actives"].append(inputID)
		else:
			DataStore.playerData["Passives"].clear()
			DataStore.playerData["Passives"].append(inputID)
		_selected.emit()

func _abButton_focused() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(abButton, "scale", Vector2(1.1, 1.1), 0.15)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)

func _abButton_unfocused() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(abButton, "scale", Vector2(1.0, 1.0), 0.2)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)

func _start_cooldown(duration):
	var shader = $Ability/abButton/Image.material
	if isAbility:
		abButton.disabled = true
		cdDisp.visible = true
		Cd.start(duration)
		abFunc.onCooldown = true
		perkBase.modulate
		#shader.set_shader_parameter("value", -0.15)
		#shader.set_shader_parameter("exposure", 0.60)
	else:
		perkCd.visible = true
		Cd.start(duration)
		abFunc.onCooldown = true

func _end_cooldown() -> void:
	var shader = $Ability/abButton/Image.material
	abButton.disabled = false
	cdDisp.visible = false
	perkCd.visible = false
	abFunc.onCooldown = false
	#shader.set_shader_parameter("value", 0.0)
	#shader.set_shader_parameter("exposure", 0.5)
