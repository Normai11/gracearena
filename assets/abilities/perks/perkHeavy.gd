extends abilityTemp

var isFF : bool = false # Fast Falling

func _ready() -> void:
	print("Loaded!")

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("down"):
		player.set_collision_mask_value(6, false)
		if !isFF:
			isFF = true
			player.velocity.y = player.dropForce
	else:
		player.set_collision_mask_value(6, true)
	
	if player.is_on_floor():
		isFF = false
