class_name Room
extends Node2D

@export var roomSize : Vector2
@export var startFlipping : bool = false
@export var roomFlipped : bool = false
@export var endGen : bool = false
@export var roomOffset : Vector2 = Vector2(0.0, 0.0)
@export var roomContObj : Marker2D

func _ready() -> void:
	if roomFlipped:
		scale.x = -1
