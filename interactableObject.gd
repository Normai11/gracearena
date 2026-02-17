class_name interactableObject
extends Node

enum refTypes {
	FOLLOW,
	LOCK
}

@export var promptName : String = ""
@export var overhaulCamera : bool = false
@export var cameraFocusMode := refTypes.LOCK
@export var cameraFocusDrag : float = 0.5
@export var cameraFocusZoom : Vector2 = Vector2(0.7, 0.7)

func _get_object_name() -> String:
	return promptName

func _interacted():
	print("object interaction")
	if overhaulCamera:
		var camera = get_parent().find_child("advCamera")
		camera.change_targets(self, cameraFocusMode, cameraFocusDrag, cameraFocusZoom)
