extends Node

@export var maxTime : float = 150.00
@export var roomgenAmt : int = 25

func _ready() -> void:
	$Timer.start(maxTime)

func _process(delta: float) -> void:
	DataStore.timer = $Timer.time_left
