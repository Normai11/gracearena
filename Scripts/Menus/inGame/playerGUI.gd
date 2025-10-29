extends CanvasLayer

@export var player : Player

@onready var hudPath = $HUDparent/Abilities
@onready var perkPath = $HUDparent/Perks
@onready var healthBar = $HUDparent/Healthbar

func _ready() -> void:
	healthBar.max_value = player.max_health

func _process(_delta: float) -> void:
	healthBar.value = player.health
	healthBar.get_child(0).text = str(int(healthBar.value))

func _refresh_perks() -> void:
	var idx = 0
	for item in DataStore.playerData["Passives"]:
		var subject = perkPath.get_child(idx)
		var texturePath = "res://Sprites/Abilities/ab" + str(int(item)) + ".png"
		player.passives.append(int(item))
		
		subject.get_child(0).texture = load(texturePath)
		subject.visible = true
		
		idx += 1
