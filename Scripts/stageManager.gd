extends Node

@export var roomgenAmt : int = 25

func _process(delta: float) -> void:
	if DataStore.timerJustActive:
		DataStore.timerJustActive = false
		DataStore.timerActive = true
		$Timer.wait_time = DataStore.timer
		$Timer.start()
	if DataStore.timerActive:
		DataStore.timer = $Timer.time_left
