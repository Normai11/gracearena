extends abilityTemp

var animTween : Tween

func formShield() -> void:
	animTween = get_tree().create_tween()
	animTween.set_ease(Tween.EASE_OUT)
	animTween.set_trans(Tween.TRANS_EXPO)
	player.guiScene.shield_anim(true)
	
	animTween.tween_property(player.guiScene.healthBar.get_child(1), "rotation_degrees", 0, 0.5)

func _ability_activate():
	abDisplay._start_cooldown(cooldown)
	player.iFrames = player.iFrameMax * 2.5
	player.guiScene.update_health()
	player.guiScene.shield_anim(false)
