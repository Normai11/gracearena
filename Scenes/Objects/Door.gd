@tool
extends Interactable

@export var doorCollision : CollisionShape2D
@export var interact : Area2D

func _interacted() -> void:
	super._interacted()
	doorCollision.disabled = true
	interact.monitorable = false
