extends Node

@export var roomgenAmt : int = 25
@export var activeMods : Array = ["Lyte"]
@export var playerReference : Player

var dict = {}

func _ready() -> void:
	for mod in activeMods:
		if DataStore.enemyModPaths.has(mod):
			var loadPath = load(DataStore.enemyModPaths.get(mod))
			var child = loadPath.instantiate()
			
			# extra logic here if needed
			
			playerReference.guiScene.call_deferred("add_child", child)

func _process(delta: float) -> void:
	if DataStore.timerJustActive:
		DataStore.timerJustActive = false
		DataStore.timerActive = true
		$Timer.wait_time = DataStore.timer
		$Timer.start()
	if DataStore.timerActive:
		DataStore.timer = $Timer.time_left
