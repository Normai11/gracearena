extends Node

func get_movement_input() -> float:
	return Input.get_axis("left", "right")

func get_jump(oneshot = false) -> bool:
	if oneshot:
		return Input.is_action_just_pressed("jump")
	else:
		return Input.is_action_pressed("jump")

func get_drop() -> bool:
	return Input.is_action_just_pressed("down")

func get_sprint() -> bool:
	return Input.is_action_pressed("sprint")
