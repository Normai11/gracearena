extends Button

func _on_pressed() -> void:
	var loadingPath = load("res://assets/menus/loadingScreen.tscn")
	Global.loadfinishPath = "res://assets/gen_test.tscn"
	get_tree().change_scene_to_packed(loadingPath)
