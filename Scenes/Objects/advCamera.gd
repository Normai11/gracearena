class_name AdvancedCamera
extends Camera2D

enum targetModes {
	FOLLOW,
	LOCK
}

@export var cameraTarget : Node2D
@export var targetMode : targetModes = targetModes.FOLLOW
@export var cameraDrag : float = 0.15
@export_custom(PROPERTY_HINT_LINK, "") var targetZoom : Vector2 = Vector2(0.7, 0.7)

var oldProperties : Array = [] # [Node2D, Drag, Zoom]

func _physics_process(_delta: float) -> void:
	if cameraTarget:
		if targetMode == targetModes.FOLLOW:
			var targetX : float = cameraTarget.global_position.x + (cameraTarget.velocity.x * 0.15)
			global_position.x = lerp(global_position.x, targetX, cameraDrag)
			global_position.y = cameraTarget.global_position.y
		else:
			global_position = cameraTarget.global_position
	zoom = lerp(zoom, targetZoom, cameraDrag)

func set_new_camera(newTarget, newMode, newDrag, newZoom) -> void:
	oldProperties.clear()
	oldProperties = [cameraTarget, targetMode, cameraDrag, targetZoom]
	
	cameraTarget = newTarget
	targetMode = newMode
	cameraDrag = newDrag
	targetZoom = newZoom
