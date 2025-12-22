extends abilityTemp

func _ability_activate():
	abDisplay._start_cooldown(cooldown)
	player.iFrames = player.iFrameMax * 2
	player.guiScene.update_health()
