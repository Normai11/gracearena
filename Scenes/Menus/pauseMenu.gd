extends Control

func _enter_tree() -> void:
	get_tree().paused = true

func _exit_tree() -> void:
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		_resume_press()

func _resume_press() -> void:
	queue_free()
