extends Node

@export var roomgenAmt : int = 25
@export var activeMods : Array = []
@export var playerReference : Player
var saferoomTimer : float = 150.9

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
		saferoomTimer = DataStore.timer
	if DataStore.timerActive:
		saferoomTimer -= delta
		DataStore.timer = saferoomTimer
