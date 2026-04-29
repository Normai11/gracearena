@tool
extends Interactable

func _interacted() -> void:
	super._interacted()
	revertCamera = !revertCamera
