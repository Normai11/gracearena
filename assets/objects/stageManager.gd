extends Node

@export var GUIEnemyParent : CanvasLayer

@export var roomgenAmt : int = 25
@export var activeMods : Array = []
@export var playerReference : Player
@export var specialStage : bool = false
var saferoomTimer : float = 150.9

func _ready() -> void:
	activeMods = DataStore.RUNDATA["activeMods"]
	
	specialStage = false
	
	for mod in activeMods:
		if DataStore.enemyModPaths.has(mod):
			var loadPath = load(DataStore.enemyModPaths.get(mod))
			var child = loadPath.instantiate()
			
			# extra logic here if needed
			
			if mod == "Lyte":
				child.playerTarget = playerReference
				GUIEnemyParent.call_deferred("add_child", child)
			elif mod == "Stargazer":
				child.playerTarget = playerReference
				GUIEnemyParent.call_deferred("add_child", child)
			else:
				child.playerTarget = playerReference
				add_child(child)

func _process(delta: float) -> void:
	if DataStore.timerJustActive:
		DataStore.timerJustActive = false
		DataStore.timerActive = true
		saferoomTimer = DataStore.timer
	if DataStore.timerActive:
		saferoomTimer -= delta
		DataStore.timer = saferoomTimer
