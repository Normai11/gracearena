extends abilityTemp

@export var healAmount : float = 10.0

func _ready() -> void:
	DataStore.saferoomIncrease.connect(_ability_activate)

func _ability_activate() -> void:
	player.health += healAmount
	player.guiScene.update_health()
