extends Node

@export var player : Player

func get_movement_input() -> float:
	return (Input.get_axis("left", "right") if player.moveType != player.moveVariants.DISABLE else 0)

func get_jump(oneshot = false) -> bool:
	if oneshot:
		return Input.is_action_just_pressed("jump")
	else:
		return Input.is_action_pressed("jump")

func can_jump() -> bool:
	if player.curJumps >= player.maxJumps + player.extraJumps:
		return false
	else:
		return true

func get_drop() -> bool:
	return Input.is_action_just_pressed("down")

func get_sprint() -> bool:
	return Input.is_action_pressed("sprint")
