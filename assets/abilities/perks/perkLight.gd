extends abilityTemp

func _ready() -> void:
	_ability_activate()

func _ability_activate():
	player.extraJumps += 1
