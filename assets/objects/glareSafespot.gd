@tool
extends Area2D

@onready var visual : ReferenceRect = $center/visual
@onready var visualCenter : CenterContainer = $center

@export var collisionSize : Vector2 = Vector2(40, 40):
	set(size):
		collisionSize = size
		if visual:
			visual.size = size
			visual.set_deferred("custom_minimum_size", Vector2(size.x, size.y))
			visualCenter.set_deferred("size", Vector2(size.x, size.y))
			visualCenter.set_deferred("position", Vector2(-size.x/2, -size.y/2))

func _ready() -> void:
	if !Engine.is_editor_hint():
		visual.queue_free()
		visualCenter.queue_free()
		#$size.shape
		$size.shape.size = collisionSize

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		$size.debug_color = Color("00ff0c42")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		$size.debug_color = Color("ffffff1f")
