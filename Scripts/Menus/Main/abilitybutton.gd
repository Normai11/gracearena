extends Control
signal _selected

@export var abilityID : int = 100 # [#]## is category, #[##] is itemID
@export var base : Button
@export var animations : AnimationPlayer

var promptID : int
var in_game : bool = false

var promptkeybind : Array = ["m1", "q", "e", "r"]

func _ready() -> void:
	var path = "res://Sprites/Abilities/ab" + str(int(abilityID)) + ".png"
	base.pressed.connect(_on_pressed)
	base.mouse_entered.connect(_focused)
	base.mouse_exited.connect(_unfocused)
	base.get_child(0).texture = load(path)
	
	if in_game:
		$Prompt.visible = true
		$Prompt.text = promptkeybind[promptID]

func _on_pressed() -> void:
	if !in_game:
		if abilityID >= 100:
			Global.playerData["Actives"][0] = abilityID
		elif abilityID <= 99:
			Global.playerData["Passives"][0] = abilityID
		_selected.emit()
	else:
		_selected.emit(abilityID)

func _focused():
	animations.play("hovering")

func _unfocused():
	animations.play("releasing")
