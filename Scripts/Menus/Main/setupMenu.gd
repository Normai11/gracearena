extends Control
signal beginPressed

@onready var gridInv = $segmentR/ScrollContainer/Inventory
@onready var buttonAb0 = $segmentL/Ability0
@onready var buttonAb1 = $segmentL/Ability1

var abButtonTemplate = preload("res://Scenes/Menus/Main/inputButton.tscn")
var pathAbilitySprite = "res://Sprites/Abilities/ab"
var invMenu : int = -1

var tweenL : Tween
var tweenR : Tween

func _ready() -> void:
	_Load_Inventory(-1)
	set_tweening(tweenL, Tween.TRANS_EXPO, Tween.EASE_OUT)
	set_tweening(tweenR, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tweenL.tween_property($segmentL, "position", Vector2(0, 0), 0.75)
	tweenR.tween_property($segmentR, "position", Vector2(498, 0), 0.75)

func set_tweening(tween, trans, TwEase):
	if tween == tweenL:
		if tweenL:
			tweenL.kill()
		tweenL = get_tree().create_tween()
		tweenL.set_trans(trans)
		tweenL.set_ease(TwEase)
	elif tween == tweenR:
		if tweenR:
			tweenR.kill()
		tweenR = get_tree().create_tween()
		tweenR.set_trans(trans)
		tweenR.set_ease(TwEase)

func _close_menu():
	set_tweening(tweenL, Tween.TRANS_SINE, Tween.EASE_OUT)
	set_tweening(tweenR, Tween.TRANS_SINE, Tween.EASE_OUT)
	tweenL.tween_property($segmentL, "position", Vector2(-504, 0), 0.5)
	tweenR.tween_property($segmentR, "position", Vector2(1210, 0), 0.5)
	await(tweenL.finished)
	queue_free()

func _Ability_Selected():
	_Load_Inventory(-1)

func _ab0_pressed() -> void:
	if invMenu == 0:
		_Load_Inventory(-1)
		return
	_Load_Inventory(0)

func _ab1_pressed() -> void:
	if invMenu == 1:
		_Load_Inventory(-1)
		return
	_Load_Inventory(1)

func _Load_Inventory(id):
	$segmentR/Inactive.visible = true
	invMenu = id
	for i in gridInv.get_children():
		i.queue_free()
	if id == 0:
		$segmentR/Inactive.visible = false
		for i in DataStore.playerData["Inventory"]:
			var ability = abButtonTemplate.instantiate()
			
			ability.inputID = i
			ability._selected.connect(_Ability_Selected)
			if i >= 100:
				gridInv.add_child(ability)
	elif id == 1:
		$segmentR/Inactive.visible = false
		for i in DataStore.playerData["Inventory"]:
			var ability = abButtonTemplate.instantiate()
			
			ability.inputID = i
			ability._selected.connect(_Ability_Selected)
			if i <= 99:
				gridInv.add_child(ability)
	
	var texturePath = pathAbilitySprite + str(int(DataStore.playerData["Actives"][0])) + ".png"
	if FileAccess.file_exists(texturePath):
		buttonAb0.get_child(0).texture = load(texturePath)
	else:
		buttonAb0.get_child(0).texture = load("res://Sprites/Abilities/holderOfPlaces.png")
	texturePath = pathAbilitySprite + str(int(DataStore.playerData["Passives"][0])) + ".png"
	if FileAccess.file_exists(texturePath):
		buttonAb1.get_child(0).texture = load(texturePath)
	else:
		buttonAb1.get_child(0).texture = load("res://Sprites/Abilities/holderOfPlaces.png")

func _focused_0() -> void:
	buttonAb0.get_child(1).play("hovering")

func _focused_1() -> void:
	buttonAb1.get_child(1).play("hovering")

func _unfocused_0() -> void:
	buttonAb0.get_child(1).play("releasing")

func _unfocused_1() -> void:
	buttonAb1.get_child(1).play("releasing")

func _on_start_pressed() -> void:
	beginPressed.emit()
