extends Node

enum crouchStates {
	NONE,
	CROUCH,
	SLIDE
}

@export var player : Player
var curCrouch : crouchStates = crouchStates.NONE
var crouchForced : bool = false

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

func get_crouch(oneshot : bool = false) -> bool:
	if oneshot:
		return Input.is_action_just_pressed("down")
	else:
		return Input.is_action_pressed("down")

func get_sprint() -> bool:
	return Input.is_action_pressed("sprint")

func get_slide() -> bool:
	return Input.is_action_pressed("down")
