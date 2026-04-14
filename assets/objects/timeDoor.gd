extends interactableObject

@onready var timer = $openTimer
@onready var collision = $collisionBox
@onready var area = $interactionArea

@export var generateRooms : bool = false
@export var roomManager : RoomManager
@export var openDuration : float = 1
@export var stageTimer : float = 150.99 
@export var forceOpen : bool = false

func _ready() -> void:
	roomManager = get_tree().current_scene.find_child("roomManager")
	timer.wait_time = openDuration
	if forceOpen:
		collision.disabled = true

func _interacted():
	if overhaulCamera:
		var camera = get_parent().find_child("advCamera")
		camera.change_targets(self, cameraFocusMode, 0.5)
	if generateRooms && roomManager:
		roomManager.roomOffset = Vector2(collision.global_position.x, collision.global_position.y + 61)
		roomManager.direction = 1
		roomManager.kill_existing_rooms()
		print(("exists" if roomManager else "no"))
		roomManager.generate_rooms()
	area.monitorable = false
	timer.start()

func _timer_timeout() -> void:
	DataStore.timerJustActive = true
	DataStore.timer = stageTimer
	collision.disabled = true
