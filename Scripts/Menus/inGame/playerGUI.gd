extends CanvasLayer

@export var player : Player

@onready var hudPath = $HUDparent/Abilities
@onready var perkPath = $HUDparent/Perks
@onready var healthBar = $HUDparent/Healthbar
@onready var perkLoad = preload("res://Scenes/Menus/Main/inputButton.tscn")

var tween : Tween

func _process(_delta: float) -> void:
	$HUDparent/timerplaceholder/display.text = str(snapped(DataStore.timer, 0.01))

func _ready() -> void:
	healthBar.max_value = player.max_health

func update_health() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(healthBar, "value", player.health, 0.2)
	healthBar.get_child(0).text = str(int(player.health))

func _refresh_perks() -> void:
	for item in DataStore.playerData["Passives"]:
		var subject = perkLoad.instantiate()
		var texturePath = "res://Sprites/Abilities/ab" + str(int(item)) + ".png"
		player.passives.append(int(item))
		
		subject.isAbility = false
		subject.inGame = true
		subject.inputID = item
		subject.texturePath = texturePath
		
		perkPath.add_child(subject)
