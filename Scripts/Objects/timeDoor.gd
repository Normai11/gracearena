extends StaticBody2D

@onready var timer = $openTimer
@onready var collision = $collisionBox
@onready var area = $interactionArea

@export var openDuration : float = 1
@export var stageTimer : float = 150.99 
@export var forceOpen : bool = false

func _ready() -> void:
	timer.wait_time = openDuration
	if forceOpen:
		collision.disabled = true

func _interacted():
	area.monitorable = false
	timer.start()

func _timer_timeout() -> void:
	DataStore.timerJustActive = true
	DataStore.timer = stageTimer
	collision.disabled = true
