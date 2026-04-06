extends Camera2D

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_up"):
		offset.y -= 50
	if Input.is_action_pressed("ui_down"):
		offset.y += 50
	if Input.is_action_pressed("left"):
		offset.x -= 50
	if Input.is_action_pressed("right"):
		offset.x += 50
	if Input.is_action_just_pressed("ui_select"):
		get_tree().reload_current_scene()
