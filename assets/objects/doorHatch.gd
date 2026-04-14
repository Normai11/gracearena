extends interactableObject

enum Biomes {
	none = -2,
	biomeTest = -1,
	tutorial = 0,
}

@onready var area = $interactionArea
@onready var collision = $CollisionShape2D

@export var saferoom : PackedScene
@export var setBiome : Biomes = Biomes.none

func _interacted():
	if overhaulCamera:
		var camera = get_parent().find_child("advCamera")
		camera.change_targets(self, cameraFocusMode, cameraFocusDrag, cameraFocusZoom)
	
	var stageManager : StageManager = get_tree().current_scene
	var manager : RoomManager = get_tree().current_scene.find_child("roomManager")
	var saferoomInstance : Room = saferoom.instantiate()
	if setBiome != Biomes.none:
		print(setBiome)
		match setBiome:
			Biomes.biomeTest:
				manager.floorBiome = -1
			Biomes.tutorial:
				manager.floorBiome = 0
	
	manager.direction = 1
	saferoomInstance.position = manager.determine_position(get_parent().roomContObj.global_position, saferoomInstance.roomConfig)
	manager.call_deferred("add_child", saferoomInstance)
	for enemy in stageManager.enemyModNodes:
		DataStore.timer = 0
		DataStore.timerActive = false
		enemy.modifier_set_active(false)
	
	area.monitorable = false
	collision.disabled = true
