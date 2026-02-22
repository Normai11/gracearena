extends Camera2D

enum camType {
	FOLLOW,
	LOCK
}

@export var targetNode : Node
@export var targetZoom : Vector2 = Vector2(0.7, 0.7)
@export var cameraType := camType.FOLLOW
@export var dragMult : float = 0.15
var curTarget

func _ready() -> void:
	curTarget = targetNode
	zoom = targetZoom
	
	if curTarget:
		position = curTarget.position
		if curTarget is Camera2D:
			curTarget = get_parent().find_child("Player")
		elif not (curTarget is CharacterBody2D):
			cameraType = camType.LOCK

func _physics_process(delta: float) -> void:
	if !curTarget:
		return
	
	zoom = lerp(zoom, targetZoom, dragMult)
	
	if cameraType == camType.FOLLOW:
		var targetPos = curTarget.position.x + (curTarget.velocity.x * 0.15)
		if DataStore.settings["toggleSmooth"]:
			position.x = lerp(position.x, targetPos, dragMult)
			position.y = curTarget.position.y
		else:
			position = curTarget.position
	elif cameraType == camType.LOCK:
		position = lerp(position, curTarget.position, dragMult)

func change_targets(newTarget : Node, focusType, newDrag : float, newZoom : Vector2) -> void:
	curTarget = newTarget
	cameraType = focusType
	dragMult = newDrag
	targetZoom = newZoom
