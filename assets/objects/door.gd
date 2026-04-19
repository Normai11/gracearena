extends interactableObject

var doorStates : Array[bool] = [false, true] ## true is tampered
var stateWeights : PackedFloat32Array = [1, 0.25]

@onready var collision = $collisionBox
@onready var area = $interactionArea

@export var tampered : bool = false
var forced : bool = false

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	if !forced:
		tampered = doorStates[rng.rand_weighted(stateWeights)]
	
	if tampered:
		area.get_child(0).debug_color = Color("ffab006b")
	
	area.monitorable = true
	area.monitoring = true

func _interacted():
	if tampered:
		return
	if overhaulCamera:
		var camera = get_parent().find_child("advCamera")
		camera.change_targets(self, cameraFocusMode, 0.5)
	area.set_deferred("monitorable", false)
	collision.set_deferred("disabled", true)

func _check_kick(body: Node2D) -> void:
	if body is Player:
		if tampered:
			if body.moveNode.curCrouch == 2 && abs(body.velocity.x) > 20:
				area.set_deferred("monitorable", false)
				collision.set_deferred("disabled", true)
		else:
			if DataStore.settings["autoInteract"]:
				_interacted()
