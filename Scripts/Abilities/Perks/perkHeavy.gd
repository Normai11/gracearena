extends abilityTemp

func _ready() -> void:
	print("Loaded!")

func _process(_delta: float) -> void:
	if Input.is_action_pressed("down"):
		player.set_collision_mask_value(6, false)
	else:
		player.set_collision_mask_value(6, true)
