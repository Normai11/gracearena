extends Control
signal beginPressed

@onready var gridInv = $ScrollContainer/Inventory
@onready var buttonAb0 = $Ability0
@onready var buttonAb1 = $Ability1

var abButtonTemplate = preload("res://Scenes/Menus/Main/abilityButton.tscn")
var pathAbilitySprite = "res://Sprites/Abilities/ab"
var invMenu : int = -1

func _ready() -> void:
	_Load_Inventory(-1)

func _close_menu():
	$WINDOW.play("close")
	await($WINDOW.animation_finished)
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
	invMenu = id
	for i in gridInv.get_children():
		i.queue_free()
	if id == 0:
		for i in DataStore.playerData["Inventory"]:
			var ability = abButtonTemplate.instantiate()
			
			ability.abilityID = i
			ability._selected.connect(_Ability_Selected)
			if i >= 100:
				gridInv.add_child(ability)
	elif id == 1:
		for i in DataStore.playerData["Inventory"]:
			var ability = abButtonTemplate.instantiate()
			
			ability.abilityID = i
			ability._selected.connect(_Ability_Selected)
			if i <= 99:
				gridInv.add_child(ability)
	
	buttonAb0.get_child(0).texture = load(pathAbilitySprite + str(int(DataStore.playerData["Actives"][0])) + ".png")
	buttonAb1.get_child(0).texture = load(pathAbilitySprite + str(int(DataStore.playerData["Passives"][0])) + ".png")

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
