class_name inputComponent
extends Node

var maxJumps : int = 1
var curJumps : int = 0
var downState : int = 0 ## 0 = Standing, 1 = Crouching, 2 = Sliding

func get_movement_input() -> float:
	return Input.get_axis("moveLeft", "moveRight")

func get_can_jump() -> bool:
	return curJumps < maxJumps
