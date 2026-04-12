@tool
extends StaticBody2D

@onready var visual : ReferenceRect = $center/visual
@onready var visualCenter : CenterContainer = $center
@onready var panelSolid : CollisionShape2D = $collision
@onready var shatterArea : CollisionShape2D = $shatterCheck/area
@onready var shatterCheck : Area2D = $shatterCheck

@export var panelLength : float = 20:
	set(length):
		panelLength = length
		if Engine.is_editor_hint():
			if visual:
				visual.set_deferred("custom_minimum_size", Vector2(length, visual.custom_minimum_size.y))
				visualCenter.set_deferred("size", Vector2(length, visualCenter.size.y))
				visualCenter.set_deferred("position", Vector2(-length/2, -20))

func _ready() -> void:
	if !Engine.is_editor_hint():
		visual.queue_free()
		panelSolid.shape.size.x = panelLength
		shatterArea.shape.size.x = panelLength

func _check_shatter(body: Node2D) -> void:
	if body is Player:
		if !body.get_collision_mask_value(8):
			queue_free()
