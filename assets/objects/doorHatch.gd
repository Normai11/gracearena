extends interactableObject

@onready var area = $interactionArea
@onready var collision = $CollisionShape2D

@export var saferoom : PackedScene

func _interacted():
	if overhaulCamera:
		var camera = get_parent().find_child("advCamera")
		camera.change_targets(self, cameraFocusMode, cameraFocusDrag, cameraFocusZoom)
	
	var stageManager : StageManager = get_tree().current_scene
	var manager : RoomManager = get_tree().current_scene.find_child("roomManager")
	var saferoomInstance : Room = saferoom.instantiate()
	
	manager.direction = 1
	saferoomInstance.position = manager.determine_position(get_parent().roomContObj.global_position, saferoomInstance.roomConfig)
	manager.call_deferred("add_child", saferoomInstance)
	for enemy in stageManager.enemyModNodes:
		DataStore.timer = 0
		DataStore.timerActive = false
		enemy.modifier_set_active(false)
	
	area.monitorable = false
	collision.disabled = true
