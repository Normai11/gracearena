extends abilityTemp

var isFF : bool = false # Fast Falling
var isSlamming : bool = false

func _ready() -> void:
	print("Loaded!")

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("down"):
		player.set_collision_mask_value(6, false)
	else:
		player.set_collision_mask_value(6, true)
	
	if Input.is_action_just_pressed("down"):
		if !isFF:
			isFF = true
			if (player.moveNode.get_movement_input() == 0 or abs(player.velocity.x) < 20) && !player.is_on_floor():
				isSlamming = true
				player.moveType = funcType.DISABLE
				player.velocity.y = player.gravity_cap
				player.set_collision_mask_value(8, false)
				force_crouchState()
			else:
				player.velocity.y = player.dropForce
	
	if player.is_on_floor():
		if !player.get_collision_mask_value(8) && isSlamming:
			isSlamming = false
			player.moveType = funcType.CONTINUE
			player.velocity.y = -player.jump_force
			player.set_collision_mask_value(8, true)
			force_crouchState(false)
		isFF = false
